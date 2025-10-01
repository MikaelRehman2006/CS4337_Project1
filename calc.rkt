#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))