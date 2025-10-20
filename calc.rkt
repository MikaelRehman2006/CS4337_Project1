#lang racket

(define interactive?
  (not (member "-b" (vector->list (current-command-line-arguments)))))


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

    
(define (process-expression history)
  (display "Enter an expression: ")
  (define user-input (read))
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (display "Error: Invalid Expression\n"))])
    ;; replace $n with history values before evaluation
    (define expr-with-values (replace-history-refs user-input history))

    ;; evaluate the substituted expression
    (define result (eval expr-with-values))

    ;; add result to history (front of list)
    (define new-history (cons result history))

    ;; calculate history id
    (define history-id (+ 1 (length history)))

    ;; show result
    (display history-id)
    (display ": ")
    (display result)
    (newline)

    ;; return updated history
    new-history))

(define (start-program history)
  (if interactive?
      (let ([new-history (process-expression history)])  ; use let instead of define
        (start-program new-history))                    ; pass updated history
      (begin
        (display "Batch mode: single expression evaluation\n")
        (process-expression history))))


(start-program '())
