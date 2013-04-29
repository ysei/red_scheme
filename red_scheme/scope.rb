module RedScheme
  class Scope
    def initialize(table={}, outer=nil)
      @table = table
      @outer = outer
    end

    def new(table={})
      Scope.new(table={}, self)
    end

    ROOT = new(:t => true,
               :nil => Nil.instance,
               :car => lambda{|arguments, scope|
                 arguments_length = arguments.length
                 raise "car: wrong number of arguments (#{arguments_length} for 1)" if arguments_length != 1
                 scope.eval(arguments.car).car
               },
               :cdr => lambda{|arguments, scope|
                 arguments_length = arguments.length
                 raise "cdr: wrong number of arguments (#{arguments_length} for 1)" if arguments_length != 1
                 scope.eval(arguments.car).cdr
               },
               :cons => lambda{|arguments, scope|
                 arguments_length = arguments.length
                 raise "cell: wrong number of arguments (#{arguments_length} for 2)" if arguments_length != 2
                 Cell.new(scope.eval(arguments.car), scope.eval(arguments.cdr.car))
               },
               :atom? => lambda{|arguments, scope|
                 arguments_length = arguments.length
                 raise "atom?: wrong number of arguments (#{arguments_length} for 1)" if arguments_length != 1
                 argument = scope.eval(arguments.car)

                 if argument.is_a? Cell
                   false
                 else
                   true
                 end
               },
               :equal? => lambda{|arguments, scope|
                 arguments_length = arguments.length
                 raise "equal?: wrong number of arguments (#{arguments_length} for 2)" if arguments_length != 2
                 a = scope.eval(arguments.car)
                 b = scope.eval(arguments.cdr.car)

                 a == b
               },
               :condition => lambda{|arguments, scope|
                 predicate = arguments.car.car
                 clause = arguments.car.cdr
                 rest = arguments.cdr

                 if scope.eval(predicate)
                   clause.each do |expression|
                     scope.eval(expression)
                   end
                 elsif rest.length > 0
                   scope.find(:condition).call(rest, scope)
                 else
                   Nil.instance
                 end
               },
               :quote => lambda{|arguments, scope|
                 arguments
               },
               :lambda => lambda{|arguments, scope|
                 parameters = arguments.car
                 body = arguments.cdr
                 Lambda.new(parameters, body, scope)
               },
               :let => lambda{|arguments, scope|
                 binds = arguments.car
                 lambda_parameters = binds.inject(Nil.instance) do |result, pair|
                   Cell.new(pair.car, result)
                 end
                 lambda_arguments = binds.inject(Nil.instance) do |result, pair|
                   Cell.new(scope.eval(pair.cdr.car), result)
                 end
                 body = arguments.cdr
                 Lambda.new(lambda_parameters, body, scope).apply(lambda_arguments)
               },
               :define => lambda{|arguments, scope|
                 variable = arguments.car
                 value = scope.eval(arguments.cdr.car)
                 scope.bind(variable, value)
                 value
               },
               :+ => lambda{|arguments, scope|
                 arguments.map{|argument| scope.eval(argument) }.inject(&:+)
               },
               :- => lambda{|arguments, scope|
                 arguments.map{|argument| scope.eval(argument) }.inject(&:-)
               },
               :* => lambda{|arguments, scope|
                 arguments.map{|argument| scope.eval(argument) }.inject(&:*)
               })

    def find(variable)
      if @table.has_key?(variable)
        @table[variable]
      elsif @outer
        @outer.find(variable)
      else
        raise "undefined local variable `#{variable} in #{@table.keys}'"
      end
    end

    def bind(variable, value)
      raise "variable is not symbol" unless variable.is_a? Symbol
      @table[variable] = value
    end

    def eval(expression)
      RedScheme.eval(expression, self)
    end
  end
end
