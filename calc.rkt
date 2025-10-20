#lang racket

(define interactive?
  (not (member "-b" (vector->list (current-command-line-arguments)))))

(define eval-ns (make-base-namespace))

;; Helper: check if a symbol is a $n reference and return its index
(define (get-history-index sym)
  (if (and (symbol? sym)
           (regexp-match #rx"^\\$[0-9]+$" (symbol->string sym)))
      (string->number (substring (symbol->string sym) 1))
      #f))

(define (replace-history-refs expr history)
  (cond
    ;; If it's a list, recursively process each element
    [(list? expr)
     (map (lambda (e) (replace-history-refs e history)) expr)]

    ;; If it's a symbol like $1, $2, etc.
    [(symbol? expr)
     (let ([index (get-history-index expr)])
       (if (and index (<= index (length history)))
           (list-ref (reverse history) (- index 1))  ; fetch value from history
           expr))]  ; leave unchanged if not found

    ;; Otherwise (number, string, etc.), just return as is
    [else expr]))

;; strict evaluator to satisfy project operator rules
(define (eval-expr expr)
  (cond
    [(number? expr) expr]
    [(list? expr)
     (if (null? expr) (error "Invalid Expression")
         (let* ([op (car expr)]
                [args (cdr expr)]
                [argc (length args)])
           (cond
             [(and (symbol? op) (eq? op '+))
              (unless (= argc 2) (error "Invalid Expression"))
              (let ([a (eval-expr (first args))]
                    [b (eval-expr (second args))])
                (if (and (number? a) (number? b)) (+ a b) (error "Invalid Expression")))]
             [(and (symbol? op) (eq? op '*))
              (unless (= argc 2) (error "Invalid Expression"))
              (let ([a (eval-expr (first args))]
                    [b (eval-expr (second args))])
                (if (and (number? a) (number? b)) (* a b) (error "Invalid Expression")))]
             [(and (symbol? op) (eq? op '/))
              (unless (= argc 2) (error "Invalid Expression"))
              (let ([a (eval-expr (first args))]
                    [b (eval-expr (second args))])
                (if (and (integer? a) (integer? b) (not (= b 0)))
                    (quotient a b)
                    (error "Invalid Expression")))]
             [(and (symbol? op) (eq? op '-))
              (unless (= argc 1) (error "Invalid Expression"))
              (let ([a (eval-expr (first args))])
                (if (number? a) (- a) (error "Invalid Expression")))]
             [else (error "Invalid Expression")])))]
    [else (error "Invalid Expression")]))

(define (process-expression history)
  (when interactive? (display "Enter an expression: "))
  (define user-input (read))

  ;; Stop reading at end of file (batch mode only)
  (when (eof-object? user-input)
    (exit))

  (when (or (equal? user-input 'quit)
            (equal? user-input 'exit))
    (display "\nExiting program. Final history:\n")
    (for ([i (in-range (length history))])
      (display (format "~a: ~a\n" (+ i 1) (list-ref (reverse history) i))))
    (display "Goodbye!\n")
    (exit))

  (with-handlers ([exn:fail?
                   (lambda (e)
                     (display "Error: Invalid Expression\n")
                     history)])
    ;; replace $n with history values before evaluation
    (define expr-with-values (replace-history-refs user-input history))

    ;; evaluate the substituted expression
    (define result (eval-expr expr-with-values))

    ;; add result to history (front of list)
    (define new-history (cons result history))

    ;; calculate history id
    (define history-id (+ 1 (length history)))

    ;; show result
    (display history-id)
    (display ": ")
    (display (if (number? result) (real->double-flonum result) result))
    (newline)

    ;; return updated history
    new-history))

(define (start-program history)
  (if interactive?
      (let ([new-history (process-expression history)])  ; use let instead of define
        (start-program new-history))                    ; pass updated history
      (let loop ([current-history history])
        (unless (eof-object? (peek-char))
          (let ([new-history (process-expression current-history)])
            (loop new-history))))))

(void (start-program '()))
