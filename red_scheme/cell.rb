module RedScheme
  class Cell
    include Enumerable
    attr_accessor :car, :cdr

    def initialize(car, cdr)
      @car = car
      @cdr = cdr
    end

    def each(&block)
      if cdr.is_a? Cell
        yield(car)
        cdr.each(&block)
      elsif cdr.is_a? Nil
        yield(car)
      else
        yield(car)
        yield(cdr)
      end
    end

    def length
      if car.is_a?(Nil) and cdr.is_a?(Nil)
        0
      elsif cdr.is_a?(Nil)
        1
      else
        1 + cdr.length
      end
    end

    def to_s
      "(#{car} . #{cdr})"
    end
  end
end
