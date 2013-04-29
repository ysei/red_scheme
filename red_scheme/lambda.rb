module RedScheme
  class Lambda
    def initialize(parameters, body, scope)
      @parameters = parameters
      @body = body
      @scope = scope.new
    end

    def apply(arguments)
      parameter_length = @parameters.length
      argument_length = arguments.length

      unless parameter_length == argument_length
        raise "wrong number of arguments (#{argument_length} for #{parameter_length})"
      end

      bind_parameters(@parameters, arguments) if parameter_length > 0

      @body.each do |expression|
        @scope.eval(expression)
      end
    end

    private
    # parameters=(a b c) arguments=(1 2 3) => (bind a 1) (bind b 2) (bind c 3)
    # parameters=(a b . c) arguments=(1 2 3 4 5) => (bind a 1) (bind b 2) (bind c (3 4 5))
    # parameters=a arguments=(1 2 3) => (bind a (1 2 3))
    def bind_parameters(parameters, arguments)
      if parameters.is_a? Cell
        @scope.bind(parameters.car, arguments.car)
        bind_parameters(parameters.cdr, arguments.cdr)
      elsif parameters.is_a? Symbol
        @scope.bind(parameters, arguments)
      elsif parameters.is_a? Nil
        # nothing to do
      else
        raise "parameter is not symbol => #{parameters}"
      end
    end
  end
end
