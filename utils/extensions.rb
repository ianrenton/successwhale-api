#!/usr/bin/env ruby
# encoding: UTF-8

# Extensions to core Ruby classes.

# Check if a string really contains an integer
class String
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end

# Remove a key from a hash
class Hash
  #pass single or array of keys, which will be removed, returning the remaining hash
  def remove!(*keys)
    keys.each{|key| self.delete(key) }
    self
  end

  #non-destructive version
  def remove(*keys)
    self.dup.remove!(*keys)
  end
end