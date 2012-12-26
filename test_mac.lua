#!/usr/bin/env luajit

ldablooms = require('ldablooms')
error_rate = 0.05

function mac_gen(random_file)
  local bytes = random_file:read(6)
  local a, b, c, d, e, f = string.byte(bytes, 1, 6)
  return string.format('%02x', a) .. ':' .. string.format('%02x', b) .. ':' .. string.format('%02x', c) .. ':' .. string.format('%02x', d) .. ':' .. string.format('%02x', e) .. ':' .. string.format('%02x', f)
end

function add_to_bloom(bloom, num)
  local rfile = io.open('/dev/urandom')
  local macfile = io.open('mac_added.txt', 'w')
  for i=1, num do
    local mac = mac_gen(rfile)
    bloom:add(mac, i)
    macfile:write(mac .. '\n')
  end
  bloom:flush()
  macfile:close()
  rfile:close()
end

function check_true(bloom)
  for mac in io.lines('mac_added.txt') do
    if bloom:check(mac) ~= true then
      io.stderr:write(string.format('ERROR: MAC %s exists in list file, but not in bloom filter', mac))
    end
  end
end

function check_maybe_false(bloom, num)
  local rfile = io.open('/dev/urandom')
  local macfile = io.open('mac_exists.txt', 'w')
  local n = 0
  for i=1, num do
    local mac = mac_gen(rfile)
    if bloom:check(mac, i) == true then
      macfile:write(mac .. '\n')
      n = n + 1
    end
  end
  rfile:close()
  print(n .. ' MAC addresses exist already. Really?')
end

function test()
  local bloom = ldablooms.Dablooms:new(100000, error_rate, 'test2.dablooms')
  os.setlocale('')
  print(os.date('%c'), 'start filling bloom filter')
  add_to_bloom(bloom, 10000000)
  print(os.date('%c'), 'finished filling bloom filter. start checking true')
  check_true(bloom)
  print(os.date('%c'), 'finished checking true. start check false')
  check_maybe_false(bloom, 10000000)
  print(os.date('%c'), 'all done')
end

test()
