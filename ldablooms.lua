#!/usr/bin/env luajit

local setmetatable = setmetatable
local type = type

local ffi = require('ffi')
require('ldablooms_header')

module(...)

local L = ffi.load('dablooms')

Dablooms = {}
Dablooms.__index = Dablooms

function Dablooms:new(capacity, error_rate, filepath)
  local self = {}
  setmetatable(self, Dablooms)
  if type(capacity) == 'object' then
    error_rate = capacity.error_rate
    filepath = capacity.filepath
    capacity = capacity.capacity
  end
  self._filter = L.new_scaling_bloom(capacity, error_rate, filepath)
  return self
end

function Dablooms:check(key)
  return L.scaling_bloom_check(self._filter, key, #key) ~= 0
end

function Dablooms:add(key, id)
  return L.scaling_bloom_add(self._filter, key, #key, id)
end

function Dablooms:delete(key, id)
  return L.scaling_bloom_remove(self._filter, key, #key, id)
end

function Dablooms:flush()
  return L.scaling_bloom_flush(self._filter)
end

function Dablooms:mem_seqnum()
  return L.scaling_bloom_mem_seqnum(self._filter)
end

function Dablooms:disk_seqnum()
  return L.scaling_bloom_disk_seqnum(self._filter)
end

function load_dabloom(capacity, error_rate, filepath)
  local self = {}
  setmetatable(self, Dablooms)
  if type(capacity) == 'object' then
    error_rate = capacity.error_rate
    filepath = capacity.filepath
    capacity = capacity.capacity
  end
  self._filter = L.new_scaling_bloom_from_file(capacity, error_rate, filepath)
  return self
end
