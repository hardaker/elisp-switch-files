(defvar switch-files-paths '("." "/home/hardaker/src/snmp/net-snmp/include" "/usr/include" "/usr/local/include")
  "the list of paths to look through for matching files.")
(defvar switch-files-list '(("\\.c" ".h")
			 ("\\.C" ".H")
			 ("\\.h" ".c")
			 ("\\.H" ".C")
			 ("\\.pm" ".xs")
			 ("\\.xs" ".pm")
			 ("\\.CPP" ".H"))
  "A list of file regexp matches and replacements switch between.")

(defvar switch-file-backto nil
  "A buffer local variable containing a buffer to jump back to for switch-file.")

(defun mytmp ()
  (interactive)
  (if
      (looking-at "#include [<\\\"]\\(\\([^/]*\\|.*/[^/]*\\)\\.h\\)[>\\\"]")
      (progn
	(message "yes")
	(message (concat "1: " (buffer-substring (match-beginning 1) (match-end 1))))
	(sleep-for 1)
	(message (buffer-substring (match-beginning 2) (match-end 2)))
	(sleep-for 2))
    (message "no")))

(defun switch-files ()
  (interactive)
  (let* ((curbuffer (current-buffer))
	 (buffername (buffer-file-name))
	 (list switch-files-list)
	 (pathlist switch-files-paths)

	 ; the name of the file to go look for.  Used for (message)s only.
	 (startfile
	  (or
	   ; are we staring at an include directive.
	   (and
	    (looking-at
	     "#include [<\\\"]\\([^/>\\\"]*\\|.*/[^/>\\\"]*\\)[>\\\"]")
	    (buffer-substring (match-beginning 1) (match-end 1)))
	   ; are we in a buffer that we know where to go back to already?
	   switch-file-backto
	   ; can we guess at a file name from the current buffer name?
	   (let ((it
		  (assoc-if (function (lambda (key) 
					(string-match
					 (concat "\\(.*\\)" key)
					 buffername)))
		  switch-files-list)))
	     (if it
		 (file-name-nondirectory
		  (concat (substring buffername (match-beginning 1)
				     (match-end 1))
			  (cadr it)))))))
	 done thefile)
    
    (if (not startfile)
	(error 'invalid-operation "no known file to switch to for this file name"))
    
    (if (bufferp startfile)
	(switch-to-buffer startfile)
      (setq done nil)
      (while (and (not done) pathlist)
	(setq thefile (expand-file-name startfile (car pathlist)))
	(if (file-exists-p thefile)
	    (setq done t)
	  (setq pathlist (cdr pathlist))))

      (if done
	  (progn
	    (find-file thefile)
	    (make-local-variable 'switch-file-backto)
	    (setq switch-file-backto curbuffer))
	(message "Can't find file: %s" startfile)
	))))

(global-set-key "\C-x\M-f" 'switch-files)

(provide 'switch-files)
