require 'singleton'
module RedScheme
  class Nil
    include Singleton

    def to_s
      "()"
    end

    def length
      0
    end
  end
end
