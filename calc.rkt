#lang racket

;; --- MODE DETECTION ---
(define interactive?
  (not (member "-b" (vector->list (current-command-line-arguments)))))

;; --- HELPER FUNCTIONS ---

;; Check if a symbol is a $n history reference
(define (get-history-index sym)
  (if (and (symbol? sym)
           (regexp-match #rx"^\\$[0-9]+$" (symbol->string sym)))
      (string->number (substring (symbol->string sym) 1))
      #f))

;; Get value from history by id
(define (get-history-value history id)
  (if (or (< id 1) (> id (length history)))
      (error "Invalid Expression")
      (list-ref (reverse history) (- id 1))))

;; --- TOKENIZATION ---

;; Skip whitespace and return remaining characters
(define (skip-whitespace chars)
  (cond
    [(null? chars) '()]
    [(char-whitespace? (car chars)) (skip-whitespace (cdr chars))]
    [else chars]))

;; Read next token from character list
;; Returns (list token remaining-chars)
(define (read-token chars)
  (define clean-chars (skip-whitespace chars))
  
  (cond
    [(null? clean-chars) (list #f '())]
    
    ;; Operators: +, *, /, -
    [(member (car clean-chars) '(#\+ #\* #\/ #\-))
     (list (car clean-chars) (cdr clean-chars))]
    
    ;; History reference: $n
    [(char=? (car clean-chars) #\$)
     (let-values ([(num-chars rest) (splitf-at (cdr clean-chars) char-numeric?)])
       (if (null? num-chars)
           (error "Invalid Expression")
           (list (string->symbol (list->string (cons #\$ num-chars))) rest)))]
    
    ;; Number (integer or float)
    [(or (char-numeric? (car clean-chars))
         (char=? (car clean-chars) #\.))
     (let-values ([(num-chars rest) 
                   (splitf-at clean-chars (lambda (c) (or (char-numeric? c) (char=? c #\.))))])
       (let ([num (string->number (list->string num-chars))])
         (if num
             (list num rest)
             (error "Invalid Expression"))))]
    
    [else (error "Invalid Expression")]))

;; --- EXPRESSION EVALUATION ---

;; Evaluate expression from character list
;; Returns (list result remaining-chars)
(define (eval-expr chars history)
  (let* ([token-pair (read-token chars)]
         [token (car token-pair)]
         [rest (cadr token-pair)])
    
    (cond
      ;; No token (EOF)
      [(not token) (error "Invalid Expression")]
      
      ;; Number literal
      [(number? token) (list token rest)]
      
      ;; History reference $n
      [(symbol? token)
       (let ([idx (get-history-index token)])
         (if idx
             (list (get-history-value history idx) rest)
             (error "Invalid Expression")))]
      
      ;; Unary minus
      [(char=? token #\-)
       (let* ([result-pair (eval-expr rest history)]
              [result (car result-pair)]
              [remaining (cadr result-pair)])
         (if (number? result)
             (list (- result) remaining)
             (error "Invalid Expression")))]
      
      ;; Binary operator: +
      [(char=? token #\+)
       (let* ([result1-pair (eval-expr rest history)]
              [result1 (car result1-pair)]
              [rest1 (cadr result1-pair)]
              [result2-pair (eval-expr rest1 history)]
              [result2 (car result2-pair)]
              [rest2 (cadr result2-pair)])
         (if (and (number? result1) (number? result2))
             (list (+ result1 result2) rest2)
             (error "Invalid Expression")))]
      
      ;; Binary operator: *
      [(char=? token #\*)
       (let* ([result1-pair (eval-expr rest history)]
              [result1 (car result1-pair)]
              [rest1 (cadr result1-pair)]
              [result2-pair (eval-expr rest1 history)]
              [result2 (car result2-pair)]
              [rest2 (cadr result2-pair)])
         (if (and (number? result1) (number? result2))
             (list (* result1 result2) rest2)
             (error "Invalid Expression")))]
      
      ;; Binary operator: /
      [(char=? token #\/)
       (let* ([result1-pair (eval-expr rest history)]
              [result1 (car result1-pair)]
              [rest1 (cadr result1-pair)]
              [result2-pair (eval-expr rest1 history)]
              [result2 (car result2-pair)]
              [rest2 (cadr result2-pair)])
         (if (and (integer? result1) (integer? result2) (not (= result2 0)))
             (list (quotient result1 result2) rest2)
             (error "Invalid Expression")))]
      
      [else (error "Invalid Expression")])))

;; --- MAIN PROCESSING ---

(define (process-expression line history)
  ;; Remove all whitespace from ends including \r\n
  (define clean-line (string-trim line))
  
  (cond
    ;; Check for quit
    [(equal? clean-line "quit") (exit)]
    
    [else
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (display "Error: Invalid Expression\n")
                        history)])
       
       ;; Parse and evaluate the expression
       (let* ([chars (string->list clean-line)]
              [result-pair (eval-expr chars history)]
              [result (car result-pair)]
              [remaining (cadr result-pair)])
         
         ;; Check if there's remaining text (error)
         (let ([remaining-clean (skip-whitespace remaining)])
           (unless (null? remaining-clean)
             (error "Invalid Expression")))
         
         ;; Add to history and print result
         (define new-history (cons result history))
         (define history-id (length new-history))
         
         (display history-id)
         (display ": ")
         (display (real->double-flonum result))
         (newline)
         
         new-history))]))

;; --- MAIN LOOP ---

(define (start-program history)
  (define (loop current-history)
    (when interactive? (display "> "))
    
    (let ([input (read-line)])
      (cond
        ;; EOF
        [(eof-object? input) (exit)]
        
        ;; Skip empty lines
        [(string=? (string-trim input) "")
         (loop current-history)]
        
        ;; Process expression
        [else
         (let ([new-history (process-expression input current-history)])
           (loop new-history))])))
  
  (loop history))

;; Start the program
(void (start-program '()))