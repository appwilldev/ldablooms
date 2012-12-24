#!/usr/bin/env luajit

local _tostring = require('logging').tostring
ldablooms = require('ldablooms')

error_rate = 0.05
words_fname = arg[1] or error("where's the words file?")
bloom = ldablooms.Dablooms:new(100000, error_rate, 'test.dablooms')

i = 0
for line in io.lines(words_fname) do
  bloom:add(line, i)
  i = i + 1
end

i = 0
for line in io.lines(words_fname) do
  if i % 5 == 0 then
    bloom:delete(line, i)
  end
  i = i + 1
end

bloom:flush()

bloom = nil
bloom = ldablooms.load_dabloom(100000, error_rate, 'test.dablooms')

true_positives = 0
true_negatives = 0
false_positives = 0
false_negatives = 0

i = 0
for line in io.lines(words_fname) do
  exists = bloom:check(line)
  if i % 5 == 0 then
    if exists then
      false_positives = false_positives + 1
    else
      true_negatives = true_negatives + 1
    end
  else
    if exists then
      true_positives = true_positives + 1
    else
      false_negatives = false_negatives + 1
      io.stderr:write(string.format("ERROR: False negative: '%s'\n", line))
    end
  end
  i = i + 1
end

false_positive_rate = false_positives / (false_positives + true_negatives)

print(string.format([[
Elements Added:   %6d
Elements Removed: %6d

True Positives:   %6d
True Negatives:   %6d
False Positives:  %6d
False Negatives:  %6d

False positive rate: %.4f]],
  i, i/5,
  true_positives,
  true_negatives,
  false_positives,
  false_negatives,
  false_positive_rate
  ))

if false_negatives > 0 then
  print("TEST FAIL (false negatives exist)")
elseif false_positive_rate > error_rate then
  print("TEST FAIL (false positive rate too high)")
else
  print("TEST PASS")
end
print("")
