; Copyright (C) 2009 Ubixum, Inc.
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
;
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public
; License along with this library; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

; this is a the default
; full speed and high speed
; descriptors found in the TRM
; change however you want but leave
; the descriptor pointers so the setupdat.c file works right


.module DEV_DSCR

; descriptor types
; same as setupdat.h
DSCR_DEVICE_TYPE=1
DSCR_CONFIG_TYPE=2
DSCR_STRING_TYPE=3
DSCR_INTERFACE_TYPE=4
DSCR_ENDPOINT_TYPE=5
DSCR_DEVQUAL_TYPE=6
DSCR_CDC_TYPE=0x24

; descriptor subtypes
DSCR_CDC_HEADER_SUBTYPE=0x00
DSCR_CDC_CALL_MGMT_SUBTYPE=0x01
DSCR_CDC_ACM_SUBTYPE=0x02
DSCR_CDC_UNION_SUBTYPE=0x06

; for the repeating interfaces
DSCR_INTERFACE_LEN=9
DSCR_ENDPOINT_LEN=7
DSCR_CDC_HEADER_LEN=5
DSCR_CDC_CALL_MGMT_LEN=5
DSCR_CDC_ACM_LEN=4
DSCR_CDC_UNION_LEN=5

; endpoint types
ENDPOINT_TYPE_CONTROL=0
ENDPOINT_TYPE_ISO=1
ENDPOINT_TYPE_BULK=2
ENDPOINT_TYPE_INT=3

    .globl  _dev_dscr, _dev_qual_dscr, _highspd_dscr, _fullspd_dscr, _dev_strings, _dev_strings_end
; These need to be in code memory.  If
; they aren't you'll have to manully copy them somewhere
; in code memory otherwise SUDPTRH:L don't work right
    .area   DSCR_AREA   (CODE)

_dev_dscr:
    .db dev_dscr_end-_dev_dscr    ; len
    .db DSCR_DEVICE_TYPE          ; type
    .dw 0x0002                    ; usb 2.0
    .db 0x02                      ; class (CDC)
    .db 0x00                      ; subclass
    .db 0x00                      ; protocol
    .db 64                        ; packet size (ep0)
    .dw 0x6666                    ; vendor id
    .dw 0x2707                    ; product id
    .dw 0x0001                    ; version id
    .db 1                         ; manufacturure str idx
    .db 2                         ; product str idx
    .db 3                         ; serial str idx
    .db 1                         ; n configurations
dev_dscr_end:

_dev_qual_dscr:
    .db dev_qualdscr_end-_dev_qual_dscr
    .db DSCR_DEVQUAL_TYPE
    .dw 0x0002                              ; usb 2.0
    .db 0x02                                ; class (CDC)
    .db 0x00                                ; subclass
    .db 0x00                                ; protocol
    .db 64                                  ; max packet
    .db 1                                   ; n configs
    .db 0                                   ; extra reserved byte
dev_qualdscr_end:

_highspd_dscr:
    .db highspd_dscr_end-_highspd_dscr      ; dscr len
    .db DSCR_CONFIG_TYPE
    ; can't use .dw because byte order is different
    .db (highspd_dscr_realend-_highspd_dscr) % 256 ; total length of config lsb
    .db (highspd_dscr_realend-_highspd_dscr) / 256 ; total length of config msb
    .db 3                                ; n interfaces
    .db 1                                ; config number
    .db 0                                ; config string
    .db 0x80                             ; attrs = bus powered, no wakeup
    .db 0xfa                             ; max power = 500ma
highspd_dscr_end:

; all the interfaces next
; NOTE the default TRM actually has more alt interfaces
; but you can add them back in if you need them.
; here, we just use the default alt setting 1 from the trm
; CDC control interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 0                ; index
    .db 0                ; alt setting idx
    .db 1                ; n endpoints
    .db 0x02             ; class (CDC)
    .db 0x02             ; subclass (ACM)
    .db 0x01             ; protocol (AT)
    .db 0                ; string index

; CDC header
    .db DSCR_CDC_HEADER_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_HEADER_SUBTYPE
    .dw 0x1001           ; CDC 1.10

; call management
    .db DSCR_CDC_CALL_MGMT_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_CALL_MGMT_SUBTYPE
    .db 0x00             ; capabilities
    .db 1                ; data interface

; ACM
    .db DSCR_CDC_ACM_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_ACM_SUBTYPE
    .db 0x02             ; capabilities (line coding and state)

; CDC union
    .db DSCR_CDC_UNION_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_UNION_SUBTYPE
    .db 0                ; master interface
    .db 1                ; slave interface

; ACM endpoint
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x81                ;  ep1 dir=in and address
    .db ENDPOINT_TYPE_INT   ; type
    .db 0x08                ; max packet LSB
    .db 0x00                ; max packet size=8 bytes
    .db 16                  ; polling interval

; CDC data interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 1                ; index
    .db 0                ; alt setting idx
    .db 2                ; n endpoints
    .db 0x0A             ; class (CDC data)
    .db 0x00             ; subclass
    .db 0x00             ; protocol
    .db 0                ; string index

; endpoint 4 out
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x04                ;  ep4 dir=OUT and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x00                ; max packet LSB
    .db 0x02                ; max packet size=512 bytes
    .db 0x00                ; polling interval

; endpoint 8 in
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x88                ;  ep8 dir=in and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x00                ; max packet LSB
    .db 0x02                ; max packet size=512 bytes
    .db 0x00                ; polling interval

; camera interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 2                ; index
    .db 0                ; alt setting idx
    .db 1                ; n endpoints
    .db 0xFF             ; class (vendor-specific)
    .db 0x00             ; subclass
    .db 0x00             ; protocol
    .db 0                ; string index

; endpoint 2 in
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x82                ; ep2 dir=in and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x00                ; max packet LSB
    .db 0x02                ; max packet size=512 bytes
    .db 0x00                ; polling interval
highspd_dscr_realend:

.even
_fullspd_dscr:
    .db fullspd_dscr_end-_fullspd_dscr      ; dscr len
    .db DSCR_CONFIG_TYPE
    ; can't use .dw because byte order is different
    .db (fullspd_dscr_realend-_fullspd_dscr) % 256 ; total length of config lsb
    .db (fullspd_dscr_realend-_fullspd_dscr) / 256 ; total length of config msb
    .db 3                                ; n interfaces
    .db 1                                ; config number
    .db 0                                ; config string
    .db 0x80                             ; attrs = bus powered, no wakeup
    .db 0xfa                             ; max power = 500ma
fullspd_dscr_end:

; all the interfaces next
; NOTE the default TRM actually has more alt interfaces
; but you can add them back in if you need them.
; here, we just use the default alt setting 1 from the trm
; CDC control interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 0                ; index
    .db 0                ; alt setting idx
    .db 1                ; n endpoints
    .db 0x02             ; class (CDC)
    .db 0x02             ; subclass (ACM)
    .db 0x01             ; protocol (AT)
    .db 0                ; string index

; CDC header
    .db DSCR_CDC_HEADER_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_HEADER_SUBTYPE
    .dw 0x1001           ; CDC 1.1.0

; call management
    .db DSCR_CDC_CALL_MGMT_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_CALL_MGMT_SUBTYPE
    .db 0x00             ; capabilities
    .db 1                ; data interface

; ACM
    .db DSCR_CDC_ACM_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_ACM_SUBTYPE
    .db 0x02             ; capabilities (line coding and state)

; CDC union
    .db DSCR_CDC_UNION_LEN
    .db DSCR_CDC_TYPE
    .db DSCR_CDC_UNION_SUBTYPE
    .db 0                ; master interface
    .db 1                ; slave interface

; ACM endpoint
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x81                ;  ep1 dir=in and address
    .db ENDPOINT_TYPE_INT   ; type
    .db 0x08                ; max packet LSB
    .db 0x00                ; max packet size=8 bytes
    .db 64                  ; polling interval

; CDC data interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 1                ; index
    .db 0                ; alt setting idx
    .db 2                ; n endpoints
    .db 0x0A             ; class (CDC data)
    .db 0x00             ; subclass
    .db 0x00             ; protocol
    .db 0                ; string index

; endpoint 4 out
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x04                ;  ep4 dir=OUT and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x40                ; max packet LSB
    .db 0x00                ; max packet size=64 bytes
    .db 0x00                ; polling interval

; endpoint 8 in
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x88                ;  ep8 dir=in and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x40                ; max packet LSB
    .db 0x00                ; max packet size=64 bytes
    .db 0x00                ; polling interval

; camera interface
    .db DSCR_INTERFACE_LEN
    .db DSCR_INTERFACE_TYPE
    .db 2                ; index
    .db 0                ; alt setting idx
    .db 1                ; n endpoints
    .db 0xFF             ; class (vendor-specific)
    .db 0x00             ; subclass
    .db 0x00             ; protocol
    .db 0                ; string index

; endpoint 2 in
    .db DSCR_ENDPOINT_LEN
    .db DSCR_ENDPOINT_TYPE
    .db 0x82                ; ep2 dir=in and address
    .db ENDPOINT_TYPE_BULK  ; type
    .db 0x40                ; max packet LSB
    .db 0x00                ; max packet size=64 bytes
    .db 0x00                ; polling interval
fullspd_dscr_realend:

.even
_dev_strings:
; sample string
_string0:
    .db string0end-_string0 ; len
    .db DSCR_STRING_TYPE
    .db 0x09, 0x04 ; 0x0409 is the language code for English.  Possible to add more codes after this.
string0end:

_string1:
    .db string1end-_string1 ; len
    .db DSCR_STRING_TYPE
    .ascii 'o'
    .db 0
    .ascii 'p'
    .db 0
    .ascii 'e'
    .db 0
    .ascii 'n'
    .db 0
    .ascii 'l'
    .db 0
    .ascii 'u'
    .db 0
    .ascii 'x'
    .db 0
string1end:

_string2:
    .db string2end-_string2 ; len
    .db DSCR_STRING_TYPE
    .ascii 'm'
    .db 0
    .ascii 'i'
    .db 0
    .ascii 'c'
    .db 0
    .ascii 'r'
    .db 0
    .ascii 'o'
    .db 0
    .ascii 'l'
    .db 0
    .ascii 'u'
    .db 0
    .ascii 'x'
    .db 0
string2end:

_string3:
    .db string3end-_string3 ; len
    .db DSCR_STRING_TYPE
    .ascii 'A'
    .db 0
    .ascii '5'
    .db 0
    .ascii '3'
    .db 0
    .ascii 'B'
    .db 0
    .ascii 'F'
    .db 0
    .ascii '6'
    .db 0
    .ascii '0'
    .db 0
    .ascii '9'
    .db 0
string3end:

; add more strings here


_dev_strings_end:
    .dw 0x0000  ; in case you wanted to look at memory between _dev_strings and _dev_strings_end
