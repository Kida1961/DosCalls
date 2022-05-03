SUBTTL  CONSTANT.INC -- Common Constants

IFNDEF @@CONSTANT@@
%OUT    CONSTANT.INC

;; FULLPATH        EQU     128
BLANK           EQU     ' '
BUFFERS         EQU     1024
COMMA           EQU     ','
CRCHAR          EQU     0DH
DALLAR          EQU     '$'
DQUORT          EQU     '"'
EOF             EQU     -1
EOFCHAR         EQU     1AH
EOS             EQU     0
EOT             EQU     -1
EQUAL           EQU     '='
FALSE           EQU     NOT TRUE
LFCHAR          EQU     0AH
;; MAXARGS         EQU     10
MAXBUFFER       EQU     128
MAXLINE         EQU     80
NOERROR         EQU     0
NULL            EQU     0
SHARP           EQU     '#'
SQUORT          EQU     "'"
TAB             EQU     09h
TRUE            EQU     0

@@CONSTANT@@    EQU     0
ENDIF
SUBTTL
