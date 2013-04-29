module RedScheme
  class << self
    def eval(expression, scope = Scope::ROOT)
      if expression.is_a? Cell
        apply(expression, scope)
      elsif expression.is_a? Symbol
        scope.find(expression)
      else
        expression
      end
    end

    def apply(cell, scope)
      car = cell.car
      cdr = cell.cdr
      procedure = if car.is_a? Cell
                    scope.eval(car)
                  elsif car.is_a? Symbol
                    scope.find(car)
                  else
                    raise "invalid procedure #{car}"
                  end

      if procedure.is_a? Lambda
        procedure.apply(cdr)
      elsif procedure.is_a? Proc # primitive procedure
        procedure.call(cdr, scope)
      else
        raise "invalid procedure #{procedure}"
      end
    end

    def convert(expression)
      if expression.is_a? Array
        if expression.empty?
          Nil.instance
        else
          car = expression[0]
          if car.is_a? Array
            car = convert(car)
          end
          Cell.new(car, convert(expression[1..-1]))
        end
      else
        expression
      end
    end

    def parse(expression)
      program = expression.strip().
        # gsub(/[^\) .]/) dot pair # (1 . 2) => (cons 1 2)
        gsub(/'\(/, '(quote ').
        gsub(/[a-zA-Z\+\-\*><=][0-9a-zA-Z\+\-=!*]*/, ':\\0').
        gsub(/\s+/, ', ').
        gsub(/\(/, '[').
        gsub(/\)/, ']')
      convert(Kernel.eval(program))
    end
  end
end
