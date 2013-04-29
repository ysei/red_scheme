require "./red_scheme"

def assert(expectation, expression)
  result = RedScheme.eval(RedScheme.parse(expression))
  if result == expectation
    print "."
  else
    puts "expected #{expectation}, but got #{result}"
  end
end

assert 3628800, <<-EXPRESSION
(* 1 2 3 4 5 6 7 8 9 10)
EXPRESSION

assert 10, <<-EXPRESSION
(+ 1 (+ 1 1) (- 10 9) 6)
EXPRESSION

assert 20, <<-EXPRESSION
(car (cdr '(10 20)))
EXPRESSION

assert 2, <<-EXPRESSION
(let ((x 2))
 (let ((fun (lambda () x)))
  (let ((x 1))  (fun))))
EXPRESSION

assert 9, <<-EXPRESSION
(let ((x 3))
  (let ((fun (lambda (y) (+ x y))))
    (+ (fun 1) (fun 2))))
EXPRESSION

assert 3, <<-EXPRESSION
(condition ((equal? 1 3) 1)
           ((equal? 2 3) 2)
           ((equal? 3 3) 3))
EXPRESSION

assert 3, <<-EXPRESSION
(condition ((equal? 1 3) 1)
           ((equal? 2 3) 2)
           (t 3))
EXPRESSION
print "\n"
