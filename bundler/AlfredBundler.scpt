FasdUAS 1.101.10   ��   ��    k             l      ��  ��    + % ///
GLOBAL PROPERTIES/VARIABLES
///      � 	 	 J   / / / 
 G L O B A L   P R O P E R T I E S / V A R I A B L E S 
 / / /     
  
 l     ��������  ��  ��        l     ��  ��    &  # Current Alfred-Bundler version     �   @ #   C u r r e n t   A l f r e d - B u n d l e r   v e r s i o n      j     �� �� "0 bundler_version BUNDLER_VERSION  m        �   
 d e v e l      l     ��������  ��  ��        l     ��  ��    / )# Path to Alfred-Bundler's root directory     �   R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y      i         I      �������� 0 get_bundler_dir  ��  ��     L      ! ! b      " # " b      $ % $ l    	 &���� & n     	 ' ( ' 1    	��
�� 
psxp ( l     )���� ) I    �� * +
�� .earsffdralis        afdr * m     ��
�� afdrcusr + �� ,��
�� 
rtyp , m    ��
�� 
ctxt��  ��  ��  ��  ��   % m   	 
 - - � . . � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - # o    ���� "0 bundler_version BUNDLER_VERSION   / 0 / l     ��������  ��  ��   0  1 2 1 l     �� 3 4��   3 / )# Path to Alfred-Bundler's data directory    4 � 5 5 R #   P a t h   t o   A l f r e d - B u n d l e r ' s   d a t a   d i r e c t o r y 2  6 7 6 i    
 8 9 8 I      �������� 0 get_data_dir  ��  ��   9 L      : : b      ; < ; l     =���� = n     > ? > I    �������� 0 get_bundler_dir  ��  ��   ?  f     ��  ��   < m     @ @ � A A 
 / d a t a 7  B C B l     ��������  ��  ��   C  D E D l     �� F G��   F ( "# Path to main Applescript Bundler    G � H H D #   P a t h   t o   m a i n   A p p l e s c r i p t   B u n d l e r E  I J I i     K L K I      �������� 0 get_as_bundler  ��  ��   L L      M M b      N O N l     P���� P n     Q R Q I    �������� 0 get_bundler_dir  ��  ��   R  f     ��  ��   O m     S S � T T 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t J  U V U l     ��������  ��  ��   V  W X W l     �� Y Z��   Y / )# Path to applescript libraries directory    Z � [ [ R #   P a t h   t o   a p p l e s c r i p t   l i b r a r i e s   d i r e c t o r y X  \ ] \ i     ^ _ ^ I      �������� 0 
get_as_dir  ��  ��   _ L      ` ` b      a b a l     c���� c n     d e d I    �������� 0 get_data_dir  ��  ��   e  f     ��  ��   b m     f f � g g & / a s s e t s / a p p l e s c r i p t ]  h i h l     ��������  ��  ��   i  j k j l     �� l m��   l # # Path to utilities directory    m � n n : #   P a t h   t o   u t i l i t i e s   d i r e c t o r y k  o p o i     q r q I      �������� 0 get_utils_dir  ��  ��   r L      s s b      t u t l     v���� v n     w x w I    �������� 0 get_data_dir  ��  ��   x  f     ��  ��   u m     y y � z z  / a s s e t s / u t i l i t y p  { | { l     ��������  ��  ��   |  } ~ } l     ��  ���     # Path to icons directory    � � � � 2 #   P a t h   t o   i c o n s   d i r e c t o r y ~  � � � i     � � � I      �������� 0 get_icons_dir  ��  ��   � L      � � b      � � � l     ����� � n     � � � I    �������� 0 get_data_dir  ��  ��   �  f     ��  ��   � m     � � � � �  / a s s e t s / i c o n s �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   �   # Path to bundler log file    � � � � 4 #   P a t h   t o   b u n d l e r   l o g   f i l e �  � � � i     � � � I      �������� 0 get_logfile  ��  ��   � k      � �  � � � r     	 � � � b      � � � l     ����� � n     � � � I    �������� 0 get_data_dir  ��  ��   �  f     ��  ��   � m     � � � � � ( / l o g s / b u n d l e r - { } . l o g � o      ���� 0 unformatted_path   �  ��� � r   
  � � � n  
  � � � I    �� ����� 0 	formatter   �  � � � o    ���� 0 unformatted_path   �  ��� � o    ���� "0 bundler_version BUNDLER_VERSION��  ��   �  f   
  � o      ���� "0 bundler_logfile BUNDLER_LOGFILE��   �  � � � l     ��������  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   ///
USER API
///     � � � � $   / / / 
 U S E R   A P I 
 / / /   �  � � � l     ��������  ��  ��   �  � � � i    " � � � I      �� ����� 0 library   �  � � � o      ���� 	0 _name   �  � � � o      ���� 0 _version   �  ��� � o      ���� 0 
_json_path  ��  ��   � k    I � �  � � � l      �� � ���   ���  Get path to specified AppleScript library, installing it first if necessary.

	Use this method to access AppleScript libraries with functions for common commands.

	This function will return script object of the appropriate library
	(installing it first if necessary), which grants you access to all the
	functions within that library.

	You can easily add your own utilities by means of JSON configuration
	files specified with the ``json_path`` argument. Please see
	`the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_
	for details of the JSON file format.

	:param _name: Name of the utility/asset to install
	:type _name: ``string``
	:param _version: (optional) Desired version of the utility/asset.
	:type _version: ``string``
	:param _json_path: (optional) Path to bundler configuration file
	:type _json_path: ``string`` (POSIX path)
	:returns: Path to utility
	:rtype: ``script object``

	    � � � �@     G e t   p a t h   t o   s p e c i f i e d   A p p l e S c r i p t   l i b r a r y ,   i n s t a l l i n g   i t   f i r s t   i f   n e c e s s a r y . 
 
 	 U s e   t h i s   m e t h o d   t o   a c c e s s   A p p l e S c r i p t   l i b r a r i e s   w i t h   f u n c t i o n s   f o r   c o m m o n   c o m m a n d s . 
 
 	 T h i s   f u n c t i o n   w i l l   r e t u r n   s c r i p t   o b j e c t   o f   t h e   a p p r o p r i a t e   l i b r a r y 
 	 ( i n s t a l l i n g   i t   f i r s t   i f   n e c e s s a r y ) ,   w h i c h   g r a n t s   y o u   a c c e s s   t o   a l l   t h e 
 	 f u n c t i o n s   w i t h i n   t h a t   l i b r a r y . 
 
 	 Y o u   c a n   e a s i l y   a d d   y o u r   o w n   u t i l i t i e s   b y   m e a n s   o f   J S O N   c o n f i g u r a t i o n 
 	 f i l e s   s p e c i f i e d   w i t h   t h e   ` ` j s o n _ p a t h ` `   a r g u m e n t .   P l e a s e   s e e 
 	 ` t h e   A l f r e d   B u n d l e r   d o c u m e n t a t i o n   < h t t p : / / s h a w n r i c e . g i t h u b . i o / a l f r e d - b u n d l e r / > ` _ 
 	 f o r   d e t a i l s   o f   t h e   J S O N   f i l e   f o r m a t . 
 
 	 : p a r a m   _ n a m e :   N a m e   o f   t h e   u t i l i t y / a s s e t   t o   i n s t a l l 
 	 : t y p e   _ n a m e :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ v e r s i o n :   ( o p t i o n a l )   D e s i r e d   v e r s i o n   o f   t h e   u t i l i t y / a s s e t . 
 	 : t y p e   _ v e r s i o n :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ j s o n _ p a t h :   ( o p t i o n a l )   P a t h   t o   b u n d l e r   c o n f i g u r a t i o n   f i l e 
 	 : t y p e   _ j s o n _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   P a t h   t o   u t i l i t y 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 �  � � � l     �� � ���   � : 4# partial support for "optional" args in Applescript    � � � � h #   p a r t i a l   s u p p o r t   f o r   " o p t i o n a l "   a r g s   i n   A p p l e s c r i p t �  � � � Z      � ����� � n     � � � I    �� ����� 0 is_empty   �  ��� � o    �� 0 _version  ��  ��   �  f      � r   	  � � � m   	 
 � � � � �  l a t e s t � o      �~�~ 0 _version  ��  ��   �  � � � Z    ! � ��}�| � n    � � � I    �{ ��z�{ 0 is_empty   �  ��y � o    �x�x 0 
_json_path  �y  �z   �  f     � r     � � � m     � � � � �   � o      �w�w 	0 _json  �}  �|   �  � � � l  " "�v � ��v   �   # path to specific utility    � � � � 4 #   p a t h   t o   s p e c i f i c   u t i l i t y �  � � � r   " 3 � � � n  " 1 � � � I   # 1�u ��t�u 
0 joiner   �  � � � J   # , � �  � � � n  # ( � � � I   $ (�s�r�q�s 0 
get_as_dir  �r  �q   �  f   # $ �  � � � o   ( )�p�p 	0 _name   �  ��o � o   ) *�n�n 0 _version  �o   �  ��m � m   , - � � � � �  /�m  �t   �  f   " # � o      �l�l 0 _library   �  ��k � Z   4I �j  =   4 < n  4 : I   5 :�i�h�i 0 folder_exists   �g o   5 6�f�f 0 _library  �g  �h    f   4 5 m   : ;�e
�e boovfals k   ? �		 

 l  ? ?�d�d   * $# if utility isn't already installed    � H #   i f   u t i l i t y   i s n ' t   a l r e a d y   i n s t a l l e d  n  ? N I   @ N�c�b�c 
0 logger    m   @ A �  l i b r a r y  m   A B �  7 8  m   B C �  I N F O  �a  n  C J!"! I   D J�`#�_�` 0 	formatter  # $%$ m   D E&& �'' 8 L i b r a r y   a t   ` { } `   n o t   f o u n d . . .% (�^( o   E F�]�] 0 _library  �^  �_  "  f   C D�a  �b    f   ? @ )*) r   O _+,+ b   O ]-.- l  O Y/�\�[/ n  O Y010 I   P Y�Z2�Y�Z 0 dirname  2 3�X3 n  P U454 I   Q U�W�V�U�W 0 get_as_bundler  �V  �U  5  f   P Q�X  �Y  1  f   O P�\  �[  . m   Y \66 �77 4 b u n d l e t s / a l f r e d . b u n d l e r . s h, o      �T�T 0 bash_bundlet  * 8�S8 Z   ` �9:�R;9 =   ` h<=< n  ` f>?> I   a f�Q@�P�Q 0 file_exists  @ A�OA o   a b�N�N 0 bash_bundlet  �O  �P  ?  f   ` a= m   f g�M
�M boovtrue: k   k �BB CDC r   k rEFE n   k pGHG 1   l p�L
�L 
strqH o   k l�K�K 0 bash_bundlet  F o      �J�J 0 bash_bundlet_cmd  D IJI r   s �KLK n  s �MNM I   t ��IO�H�I 
0 joiner  O PQP J   t RR STS o   t u�G�G 0 bash_bundlet_cmd  T UVU m   u xWW �XX  a p p l e s c r i p tV YZY o   x y�F�F 	0 _name  Z [\[ o   y z�E�E 0 _version  \ ]�D] o   z {�C�C 0 
_json_path  �D  Q ^�B^ 1    ��A
�A 
spac�B  �H  N  f   s tL o      �@�@ 0 cmd  J _`_ r   � �aba n  � �cdc I   � ��?e�>�? 0 prepare_cmd  e f�=f o   � ��<�< 0 cmd  �=  �>  d  f   � �b o      �;�; 0 cmd  ` ghg n  � �iji I   � ��:k�9�: 
0 logger  k lml m   � �nn �oo  l i b r a r ym pqp m   � �rr �ss  8 4q tut m   � �vv �ww  I N F Ou x�8x n  � �yzy I   � ��7{�6�7 0 	formatter  { |}| m   � �~~ � < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . .} ��5� o   � ��4�4 0 cmd  �5  �6  z  f   � ��8  �9  j  f   � �h ��� r   � ���� l  � ���3�2� I  � ��1��0
�1 .sysoexecTEXT���     TEXT� o   � ��/�/ 0 cmd  �0  �3  �2  � o      �.�. 0 	full_path  � ��-� L   � ��� I  � ��,��+
�, .sysoloadscpt        file� o   � ��*�* 0 	full_path  �+  �-  �R  ; k   � ��� ��� r   � ���� n  � ���� I   � ��)��(�) 
0 logger  � ��� m   � ��� ���  l i b r a r y� ��� m   � ��� ���  8 8� ��� m   � ��� ��� 
 E R R O R� ��'� n  � ���� I   � ��&��%�& 0 	formatter  � ��� m   � ��� ��� T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t .� ��$� o   � ��#�# 0 bash_bundlet  �$  �%  �  f   � ��'  �(  �  f   � �� o      �"�" 0 	error_msg  � ��!� R   � �� ��
�  .ascrerr ****      � ****� o   � ��� 0 	error_msg  � ���
� 
errn� m   � ��� �  �!  �S  �j   k   �I�� ��� l  � �����  � ' !# if utility is already installed   � ��� B #   i f   u t i l i t y   i s   a l r e a d y   i n s t a l l e d� ��� n  � ���� I   � ����� 
0 logger  � ��� m   � ��� ���  l i b r a r y� ��� m   � ��� ���  9 3� ��� m   � ��� ���  I N F O� ��� n  � ���� I   � ����� 0 	formatter  � ��� m   � ��� ��� 0 L i b r a r y   a t   ` { } `   f o u n d . . .� ��� o   � ��� 0 _library  �  �  �  f   � ��  �  �  f   � �� ��� l  � �����  � " # read utilities invoke file   � ��� 8 #   r e a d   u t i l i t i e s   i n v o k e   f i l e� ��� r   � ���� b   � ���� o   � ��� 0 _library  � m   � ��� ���  / i n v o k e� o      �� 0 invoke_file  � ��� Z   I����� =   ��� n  ��� I  ���� 0 file_exists  � ��� o  �� 0 invoke_file  �  �  �  f   � m  �

�
 boovtrue� k  $�� ��� r  ��� n ��� I  �	���	 0 	read_file  � ��� o  �� 0 invoke_file  �  �  �  f  � o      �� 0 invoke_path  � ��� l ����  � - '# combine utility path with invoke path   � ��� N #   c o m b i n e   u t i l i t y   p a t h   w i t h   i n v o k e   p a t h� ��� r  ��� b  ��� b  ��� o  �� 0 _library  � m  �� ���  /� o  �� 0 invoke_path  � o      �� 0 	full_path  � �� � L  $�� I #�����
�� .sysoloadscpt        file� o  ���� 0 	full_path  ��  �   �  � k  'I�� ��� r  '@   n '> I  (>������ 
0 logger    m  (+ �  l i b r a r y 	
	 m  +. �  1 0 3
  m  .1 � 
 E R R O R �� n 1: I  2:������ 0 	formatter    m  25 � R I n t e r n a l   i n v o k e   f i l e   ` { } `   d o e s   n o t   e x i s t . �� o  56���� 0 invoke_file  ��  ��    f  12��  ��    f  '( o      ���� 0 	error_msg  � �� R  AI��
�� .ascrerr ****      � **** o  GH���� 0 	error_msg   ����
�� 
errn m  EF���� ��  ��  �  �k   �  l     ��������  ��  ��    !  l     ��������  ��  ��  ! "#" i   # &$%$ I      ��&���� 0 utility  & '(' o      ���� 	0 _name  ( )*) o      ���� 0 _version  * +��+ o      ���� 0 
_json_path  ��  ��  % k    E,, -.- l      ��/0��  /	  Get path to specified utility or asset, installing it first if necessary.

	Use this method to access common command line utilities, such as
	`cocaoDialog <http://mstratman.github.io/cocoadialog/>`_ or
	`Terminal-Notifier <https://github.com/alloy/terminal-notifier>`_.

	This function will return the path to the appropriate executable
	(installing it first if necessary), which you can then utilise via
	:command:`do shell script`.

	You can easily add your own utilities by means of JSON configuration
	files specified with the ``json_path`` argument. Please see
	`the Alfred Bundler documentation <http://shawnrice.github.io/alfred-bundler/>`_ 
	for details of the JSON file format.

	:param _name: Name of the utility/asset to install
	:type _name: ``string``
	:param _version: (optional) Desired version of the utility/asset.
	:type _version: ``string``
	:param _json_path: (optional) Path to bundler configuration file
	:type _json_path: ``string`` (POSIX path)
	:returns: Path to utility
	:rtype: ``string`` (POSIX path)

	   0 �11     G e t   p a t h   t o   s p e c i f i e d   u t i l i t y   o r   a s s e t ,   i n s t a l l i n g   i t   f i r s t   i f   n e c e s s a r y . 
 
 	 U s e   t h i s   m e t h o d   t o   a c c e s s   c o m m o n   c o m m a n d   l i n e   u t i l i t i e s ,   s u c h   a s 
 	 ` c o c a o D i a l o g   < h t t p : / / m s t r a t m a n . g i t h u b . i o / c o c o a d i a l o g / > ` _   o r 
 	 ` T e r m i n a l - N o t i f i e r   < h t t p s : / / g i t h u b . c o m / a l l o y / t e r m i n a l - n o t i f i e r > ` _ . 
 
 	 T h i s   f u n c t i o n   w i l l   r e t u r n   t h e   p a t h   t o   t h e   a p p r o p r i a t e   e x e c u t a b l e 
 	 ( i n s t a l l i n g   i t   f i r s t   i f   n e c e s s a r y ) ,   w h i c h   y o u   c a n   t h e n   u t i l i s e   v i a 
 	 : c o m m a n d : ` d o   s h e l l   s c r i p t ` . 
 
 	 Y o u   c a n   e a s i l y   a d d   y o u r   o w n   u t i l i t i e s   b y   m e a n s   o f   J S O N   c o n f i g u r a t i o n 
 	 f i l e s   s p e c i f i e d   w i t h   t h e   ` ` j s o n _ p a t h ` `   a r g u m e n t .   P l e a s e   s e e 
 	 ` t h e   A l f r e d   B u n d l e r   d o c u m e n t a t i o n   < h t t p : / / s h a w n r i c e . g i t h u b . i o / a l f r e d - b u n d l e r / > ` _   
 	 f o r   d e t a i l s   o f   t h e   J S O N   f i l e   f o r m a t . 
 
 	 : p a r a m   _ n a m e :   N a m e   o f   t h e   u t i l i t y / a s s e t   t o   i n s t a l l 
 	 : t y p e   _ n a m e :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ v e r s i o n :   ( o p t i o n a l )   D e s i r e d   v e r s i o n   o f   t h e   u t i l i t y / a s s e t . 
 	 : t y p e   _ v e r s i o n :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ j s o n _ p a t h :   ( o p t i o n a l )   P a t h   t o   b u n d l e r   c o n f i g u r a t i o n   f i l e 
 	 : t y p e   _ j s o n _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   P a t h   t o   u t i l i t y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	. 232 l     ��45��  4 : 4# partial support for "optional" args in Applescript   5 �66 h #   p a r t i a l   s u p p o r t   f o r   " o p t i o n a l "   a r g s   i n   A p p l e s c r i p t3 787 Z     9:����9 n    ;<; I    ��=���� 0 is_empty  = >��> o    ���� 0 _version  ��  ��  <  f     : r   	 ?@? m   	 
AA �BB  l a t e s t@ o      ���� 0 _version  ��  ��  8 CDC Z    !EF����E n   GHG I    ��I���� 0 is_empty  I J��J o    ���� 0 
_json_path  ��  ��  H  f    F r    KLK m    MM �NN  L o      ���� 	0 _json  ��  ��  D OPO l  " "��QR��  Q   # path to specific utility   R �SS 4 #   p a t h   t o   s p e c i f i c   u t i l i t yP TUT r   " 3VWV n  " 1XYX I   # 1��Z���� 
0 joiner  Z [\[ J   # ,]] ^_^ n  # (`a` I   $ (�������� 0 get_utils_dir  ��  ��  a  f   # $_ bcb o   ( )���� 	0 _name  c d��d o   ) *���� 0 _version  ��  \ e��e m   , -ff �gg  /��  ��  Y  f   " #W o      ���� 0 _utility  U h��h Z   4Eij��ki =   4 <lml n  4 :non I   5 :��p���� 0 folder_exists  p q��q o   5 6���� 0 _utility  ��  ��  o  f   4 5m m   : ;��
�� boovfalsj k   ? �rr sts l  ? ?��uv��  u * $# if utility isn't already installed   v �ww H #   i f   u t i l i t y   i s n ' t   a l r e a d y   i n s t a l l e dt xyx n  ? Nz{z I   @ N��|���� 
0 logger  | }~} m   @ A ���  u t i l i t y~ ��� m   A B�� ���  1 4 6� ��� m   B C�� ���  I N F O� ���� n  C J��� I   D J������� 0 	formatter  � ��� m   D E�� ��� 8 U t i l i t y   a t   ` { } `   n o t   f o u n d . . .� ���� o   E F���� 0 _utility  ��  ��  �  f   C D��  ��  {  f   ? @y ��� r   O _��� b   O ]��� l  O Y������ n  O Y��� I   P Y������� 0 dirname  � ���� n  P U��� I   Q U�������� 0 get_as_bundler  ��  ��  �  f   P Q��  ��  �  f   O P��  ��  � m   Y \�� ��� 4 b u n d l e t s / a l f r e d . b u n d l e r . s h� o      ���� 0 bash_bundlet  � ���� Z   ` ������� =   ` h��� n  ` f��� I   a f������� 0 file_exists  � ���� o   a b���� 0 bash_bundlet  ��  ��  �  f   ` a� m   f g��
�� boovtrue� k   k ��� ��� r   k r��� n   k p��� 1   l p��
�� 
strq� o   k l���� 0 bash_bundlet  � o      ���� 0 bash_bundlet_cmd  � ��� r   s ���� n  s ���� I   t �������� 
0 joiner  � ��� J   t �� ��� o   t u���� 0 bash_bundlet_cmd  � ��� m   u x�� ���  u t i l i t y� ��� o   x y���� 	0 _name  � ��� o   y z���� 0 _version  � ���� o   z {���� 0 
_json_path  ��  � ���� 1    ���
�� 
spac��  ��  �  f   s t� o      ���� 0 cmd  � ��� r   � ���� n  � ���� I   � �������� 0 prepare_cmd  � ���� o   � ����� 0 cmd  ��  ��  �  f   � �� o      ���� 0 cmd  � ��� n  � ���� I   � �������� 
0 logger  � ��� m   � ��� ���  u t i l i t y� ��� m   � ��� ���  1 5 2� ��� m   � ��� ���  I N F O� ���� n  � ���� I   � �������� 0 	formatter  � ��� m   � ��� ��� < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . .� ���� o   � ����� 0 cmd  ��  ��  �  f   � ���  ��  �  f   � �� ��� r   � ���� l  � ������� I  � ������
�� .sysoexecTEXT���     TEXT� o   � ����� 0 cmd  ��  ��  ��  � o      ���� 0 	full_path  � ���� L   � ��� o   � ����� 0 	full_path  ��  ��  � k   � ��� ��� r   � ���� n  � ���� I   � �������� 
0 logger  � ��� m   � ��� ���  u t i l i t y� ��� m   � �   �  1 5 6�  m   � � � 
 E R R O R �� n  � � I   � ���	���� 0 	formatter  	 

 m   � � � T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t . �� o   � ����� 0 bash_bundlet  ��  ��    f   � ���  ��  �  f   � �� o      ���� 0 	error_msg  �  R   � ��
� .ascrerr ****      � **** o   � ��~�~ 0 	error_msg   �}�|
�} 
errn m   � ��{�{ �|   �z l  � ��y�y   / )##TODO: need a stable error number schema    � R # # T O D O :   n e e d   a   s t a b l e   e r r o r   n u m b e r   s c h e m a�z  ��  ��  k k   �E  l  � ��x�x   ' !# if utility is already installed    � B #   i f   u t i l i t y   i s   a l r e a d y   i n s t a l l e d  n  � � !  I   � ��w"�v�w 
0 logger  " #$# m   � �%% �&&  u t i l i t y$ '(' m   � �)) �**  1 6 2( +,+ m   � �-- �..  I N F O, /�u/ n  � �010 I   � ��t2�s�t 0 	formatter  2 343 m   � �55 �66 0 U t i l i t y   a t   ` { } `   f o u n d . . .4 7�r7 o   � ��q�q 0 _utility  �r  �s  1  f   � ��u  �v  !  f   � � 898 l  � ��p:;�p  : " # read utilities invoke file   ; �<< 8 #   r e a d   u t i l i t i e s   i n v o k e   f i l e9 =>= r   � �?@? b   � �ABA o   � ��o�o 0 _utility  B m   � �CC �DD  / i n v o k e@ o      �n�n 0 invoke_file  > E�mE Z   �EFG�lHF =   �IJI n  �KLK I   ��kM�j�k 0 file_exists  M N�iN o   � �h�h 0 invoke_file  �i  �j  L  f   � �J m  �g
�g boovtrueG k  	OO PQP r  	RSR n 	TUT I  
�fV�e�f 0 	read_file  V W�dW o  
�c�c 0 invoke_file  �d  �e  U  f  	
S o      �b�b 0 invoke_path  Q XYX l �aZ[�a  Z - '# combine utility path with invoke path   [ �\\ N #   c o m b i n e   u t i l i t y   p a t h   w i t h   i n v o k e   p a t hY ]^] r  _`_ b  aba b  cdc o  �`�` 0 _utility  d m  ee �ff  /b o  �_�_ 0 invoke_path  ` o      �^�^ 0 	full_path  ^ g�]g L  hh o  �\�\ 0 	full_path  �]  �l  H k  !Eii jkj r  !:lml n !8non I  "8�[p�Z�[ 
0 logger  p qrq m  "%ss �tt  u t i l i t yr uvu m  %(ww �xx  1 7 1v yzy m  (+{{ �|| 
 E R R O Rz }�Y} n +4~~ I  ,4�X��W�X 0 	formatter  � ��� m  ,/�� ��� R I n t e r n a l   i n v o k e   f i l e   ` { } `   d o e s   n o t   e x i s t .� ��V� o  /0�U�U 0 invoke_file  �V  �W    f  +,�Y  �Z  o  f  !"m o      �T�T 0 	error_msg  k ��� R  ;C�S��
�S .ascrerr ****      � ****� o  AB�R�R 0 	error_msg  � �Q��P
�Q 
errn� m  ?@�O�O �P  � ��N� l DD�M���M  � / )##TODO: need a stable error number schema   � ��� R # # T O D O :   n e e d   a   s t a b l e   e r r o r   n u m b e r   s c h e m a�N  �m  ��  # ��� l     �L�K�J�L  �K  �J  � ��� l     �I�H�G�I  �H  �G  � ��� i   ' *��� I      �F��E�F 0 icon  � ��� o      �D�D 	0 _font  � ��� o      �C�C 	0 _name  � ��� o      �B�B 
0 _color  � ��A� o      �@�@ 
0 _alter  �A  �E  � k    �� ��� l      �?���?  ���  Get path to specified icon, downloading it first if necessary.

	``_font``, ``_icon`` and ``_color`` are normalised to lowercase. In
	addition, ``_color`` is expanded to 6 characters if only 3 are passed.

	:param _font: name of the font
	:type _font: ``string``
	:param _icon: name of the font character
	:type _icon: ``string``
	:param _color: (optional) CSS colour in format "xxxxxx" (no preceding #)
	:type _color: ``string``
	:param _alter: (optional) Automatically adjust icon colour to light/dark theme background
	:type _alter: ``Boolean``
	:returns: path to icon file
	:rtype: ``string``

	See http://icons.deanishe.net to view available icons.

	   � ���$     G e t   p a t h   t o   s p e c i f i e d   i c o n ,   d o w n l o a d i n g   i t   f i r s t   i f   n e c e s s a r y . 
 
 	 ` ` _ f o n t ` ` ,   ` ` _ i c o n ` `   a n d   ` ` _ c o l o r ` `   a r e   n o r m a l i s e d   t o   l o w e r c a s e .   I n 
 	 a d d i t i o n ,   ` ` _ c o l o r ` `   i s   e x p a n d e d   t o   6   c h a r a c t e r s   i f   o n l y   3   a r e   p a s s e d . 
 
 	 : p a r a m   _ f o n t :   n a m e   o f   t h e   f o n t 
 	 : t y p e   _ f o n t :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ i c o n :   n a m e   o f   t h e   f o n t   c h a r a c t e r 
 	 : t y p e   _ i c o n :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ c o l o r :   ( o p t i o n a l )   C S S   c o l o u r   i n   f o r m a t   " x x x x x x "   ( n o   p r e c e d i n g   # ) 
 	 : t y p e   _ c o l o r :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ a l t e r :   ( o p t i o n a l )   A u t o m a t i c a l l y   a d j u s t   i c o n   c o l o u r   t o   l i g h t / d a r k   t h e m e   b a c k g r o u n d 
 	 : t y p e   _ a l t e r :   ` ` B o o l e a n ` ` 
 	 : r e t u r n s :   p a t h   t o   i c o n   f i l e 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	 S e e   h t t p : / / i c o n s . d e a n i s h e . n e t   t o   v i e w   a v a i l a b l e   i c o n s . 
 
 	� ��� l     �>���>  � : 4# partial support for "optional" args in Applescript   � ��� h #   p a r t i a l   s u p p o r t   f o r   " o p t i o n a l "   a r g s   i n   A p p l e s c r i p t� ��� Z     !���=�<� n    ��� I    �;��:�; 0 is_empty  � ��9� o    �8�8 
0 _color  �9  �:  �  f     � k   	 �� ��� r   	 ��� m   	 
�� ���  0 0 0 0 0 0� o      �7�7 
0 _color  � ��6� Z    ���5�4� n   ��� I    �3��2�3 0 is_empty  � ��1� o    �0�0 
0 _alter  �1  �2  �  f    � r    ��� m    �/
�/ boovtrue� o      �.�. 
0 _alter  �5  �4  �6  �=  �<  � ��� Z   " 2���-�,� n  " (��� I   # (�+��*�+ 0 is_empty  � ��)� o   # $�(�( 
0 _alter  �)  �*  �  f   " #� r   + .��� m   + ,�'
�' boovfals� o      �&�& 
0 _alter  �-  �,  � ��� l  3 3�%���%  �  # path to specific icon   � ��� . #   p a t h   t o   s p e c i f i c   i c o n� ��� r   3 E��� n  3 C��� I   4 C�$��#�$ 
0 joiner  � ��� J   4 >�� ��� n  4 9��� I   5 9�"�!� �" 0 get_icons_dir  �!  �   �  f   4 5� ��� o   9 :�� 	0 _font  � ��� o   : ;�� 
0 _color  � ��� o   ; <�� 	0 _name  �  � ��� m   > ?�� ���  /�  �#  �  f   3 4� o      �� 	0 _icon  � ��� Z   F����� =   F N��� n  F L��� I   G L���� 0 folder_exists  � ��� o   G H�� 	0 _icon  �  �  �  f   F G� m   L M�
� boovfals� k   Q ��� ��� l  Q Q����  � ' !# if icon isn't already installed   � ��� B #   i f   i c o n   i s n ' t   a l r e a d y   i n s t a l l e d� ��� n  Q `��� I   R `���� 
0 logger  � ��� m   R S�� ���  i c o n�    m   S T �  2 1 3  m   T U �  I N F O � n  U \	
	 I   V \��� 0 	formatter    m   V W � 2 I c o n   a t   ` { } `   n o t   f o u n d . . . � o   W X�� 	0 _icon  �  �  
  f   U V�  �  �  f   Q R�  r   a o b   a m l  a k�
�	 n  a k I   b k��� 0 dirname   � n  b g I   c g���� 0 get_as_bundler  �  �    f   b c�  �    f   a b�
  �	   m   k l � 4 b u n d l e t s / a l f r e d . b u n d l e r . s h o      �� 0 bash_bundlet    �  Z   p �!"� #! =   p x$%$ n  p v&'& I   q v��(���� 0 file_exists  ( )��) o   q r���� 0 bash_bundlet  ��  ��  '  f   p q% m   v w��
�� boovtrue" k   { �** +,+ r   { �-.- n   { �/0/ 1   | ���
�� 
strq0 o   { |���� 0 bash_bundlet  . o      ���� 0 bash_bundlet_cmd  , 121 r   � �343 n  � �565 I   � ���7���� 
0 joiner  7 898 J   � �:: ;<; o   � ����� 0 bash_bundlet_cmd  < =>= m   � �?? �@@  i c o n> ABA o   � ����� 	0 _font  B CDC o   � ����� 	0 _name  D EFE o   � ����� 
0 _color  F G��G o   � ����� 
0 _alter  ��  9 H��H 1   � ���
�� 
spac��  ��  6  f   � �4 o      ���� 0 cmd  2 IJI r   � �KLK n  � �MNM I   � ���O���� 0 prepare_cmd  O P��P o   � ����� 0 cmd  ��  ��  N  f   � �L o      ���� 0 cmd  J QRQ n  � �STS I   � ���U���� 
0 logger  U VWV m   � �XX �YY  i c o nW Z[Z m   � �\\ �]]  2 1 9[ ^_^ m   � �`` �aa  I N F O_ b��b n  � �cdc I   � ���e���� 0 	formatter  e fgf m   � �hh �ii < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . .g j��j o   � ����� 0 cmd  ��  ��  d  f   � ���  ��  T  f   � �R k��k r   � �lml l  � �n����n I  � ���o��
�� .sysoexecTEXT���     TEXTo o   � ����� 0 cmd  ��  ��  ��  m o      ���� 0 	full_path  ��  �   # k   � �pp qrq r   � �sts n  � �uvu I   � ���w���� 
0 logger  w xyx m   � �zz �{{  i c o ny |}| m   � �~~ �  2 2 2} ��� m   � ��� ��� 
 E R R O R� ���� n  � ���� I   � �������� 0 	formatter  � ��� m   � ��� ��� T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t .� ���� o   � ����� 0 bash_bundlet  ��  ��  �  f   � ���  ��  v  f   � �t o      ���� 0 	error_msg  r ���� R   � �����
�� .ascrerr ****      � ****� o   � ����� 0 	error_msg  � �����
�� 
errn� m   � ����� ��  ��  �  �  � k   ��� ��� l  � �������  � $ # if icon is already installed   � ��� < #   i f   i c o n   i s   a l r e a d y   i n s t a l l e d� ��� n  � ���� I   � �������� 
0 logger  � ��� m   � ��� ���  i c o n� ��� m   � ��� ���  I N F O� ���� n  � ���� I   � �������� 0 	formatter  � ��� m   � ��� ��� * I c o n   a t   ` { } `   f o u n d . . .� ���� o   � ����� 	0 _icon  ��  ��  �  f   � ���  ��  �  f   � �� ���� L   ��� o   � ���� 	0 _icon  ��  �  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l      ������  �   ///
LOGGING HANDLER
///    � ��� 2   / / / 
 L O G G I N G   H A N D L E R 
 / / /  � ��� l     ��������  ��  ��  � ��� i   + .��� I      ������� 
0 logger  � ��� o      ���� 0 _handler  � ��� o      ���� 0 line_num  � ��� o      ���� 
0 _level  � ���� o      ���� 0 _message  ��  ��  � k     ��� ��� l      ������  �82 Log information in the standard Alfred-Bundler log file.
	This AppleScript logger will save the `_message` with appropriate information
	in this format:
		'[%(asctime)s] [%(filename)s:%(lineno)s] '
		'[%(levelname)s] %(message)s',
		datefmt='%Y-%m-%d %H:%M:%S'
	It will then return the information in this format:
		'[%(asctime)s] [%(filename)s:%(lineno)s] '
		'[%(levelname)s] %(message)s',
		datefmt='%H:%M:%S'

	:param: _handler: name of the function where the script it running
	:type _handler: ``string``
	:param: line_num: number of the line of action for logging
	:type line_num: ``string``
	:param _level: type of logging information (INFO or DEBUG)
	:type _level: ``string``
	:param _message: message to be logged
	:type _message: ``string``
	:returns: a properly formatted log message
	:rtype: ``string``

	   � ���d   L o g   i n f o r m a t i o n   i n   t h e   s t a n d a r d   A l f r e d - B u n d l e r   l o g   f i l e . 
 	 T h i s   A p p l e S c r i p t   l o g g e r   w i l l   s a v e   t h e   ` _ m e s s a g e `   w i t h   a p p r o p r i a t e   i n f o r m a t i o n 
 	 i n   t h i s   f o r m a t : 
 	 	 ' [ % ( a s c t i m e ) s ]   [ % ( f i l e n a m e ) s : % ( l i n e n o ) s ]   ' 
 	 	 ' [ % ( l e v e l n a m e ) s ]   % ( m e s s a g e ) s ' , 
 	 	 d a t e f m t = ' % Y - % m - % d   % H : % M : % S ' 
 	 I t   w i l l   t h e n   r e t u r n   t h e   i n f o r m a t i o n   i n   t h i s   f o r m a t : 
 	 	 ' [ % ( a s c t i m e ) s ]   [ % ( f i l e n a m e ) s : % ( l i n e n o ) s ]   ' 
 	 	 ' [ % ( l e v e l n a m e ) s ]   % ( m e s s a g e ) s ' , 
 	 	 d a t e f m t = ' % H : % M : % S ' 
 
 	 : p a r a m :   _ h a n d l e r :   n a m e   o f   t h e   f u n c t i o n   w h e r e   t h e   s c r i p t   i t   r u n n i n g 
 	 : t y p e   _ h a n d l e r :   ` ` s t r i n g ` ` 
 	 : p a r a m :   l i n e _ n u m :   n u m b e r   o f   t h e   l i n e   o f   a c t i o n   f o r   l o g g i n g 
 	 : t y p e   l i n e _ n u m :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ l e v e l :   t y p e   o f   l o g g i n g   i n f o r m a t i o n   ( I N F O   o r   D E B U G ) 
 	 : t y p e   _ l e v e l :   ` ` s t r i n g ` ` 
 	 : p a r a m   _ m e s s a g e :   m e s s a g e   t o   b e   l o g g e d 
 	 : t y p e   _ m e s s a g e :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   a   p r o p e r l y   f o r m a t t e d   l o g   m e s s a g e 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	� ��� l     ������  � E ?# Ensure log file exists, with checking for scope of global var   � ��� ~ #   E n s u r e   l o g   f i l e   e x i s t s ,   w i t h   c h e c k i n g   f o r   s c o p e   o f   g l o b a l   v a r� ��� Q     7���� n   ��� I    ������� 0 
check_file  � ���� n   	��� I    	�������� 0 get_logfile  ��  ��  �  f    ��  ��  �  f    � R      ������
�� .ascrerr ****      � ****��  ��  � k    7�� ��� r    ,��� n   &��� I    &������� 0 	formatter  � ��� l   ������ b    ��� n   ��� I    �������� 0 get_data_dir  ��  ��  �  f    � m    �� ��� ( / l o g s / b u n d l e r - { } . l o g��  ��  � ���� o    "���� "0 bundler_version BUNDLER_VERSION��  ��  �  f    � n     ��� I   ' +�������� 0 get_logfile  ��  ��  �  f   & '� ���� n  - 7��� I   . 7������� 0 
check_file  � ���� n  . 3��� I   / 3�������� 0 get_logfile  ��  ��  �  f   . /��  ��  �  f   - .��  � ��� l  8 8������  � . (# delay to ensure IO action is completed   � ��� P #   d e l a y   t o   e n s u r e   I O   a c t i o n   i s   c o m p l e t e d� ��� I  8 =�� ��
�� .sysodelanull��� ��� nmbr  m   8 9 ?���������  �  l  > >����   4 .# Prepare time string format %Y-%m-%d %H:%M:%S    � \ #   P r e p a r e   t i m e   s t r i n g   f o r m a t   % Y - % m - % d   % H : % M : % S  r   > I	
	 b   > G b   > E m   > ? �  [ l  ? D���� n  ? D I   @ D�������� 0 date_formatter  ��  ��    f   ? @��  ��   m   E F �  ]
 o      ���� 0 log_time    r   J a c   J _ n   J [ 7  Q [��
�� 
citm m   U W����  m   X Z������ l  J Q ����  n   J Q!"! 1   O Q��
�� 
tstr" l  J O#��~# I  J O�}�|�{
�} .misccurdldt    ��� null�|  �{  �  �~  ��  ��   m   [ ^�z
�z 
TEXT o      �y�y 0 formatterted_time   $%$ r   b m&'& b   b k()( b   b g*+* m   b e,, �--  [+ o   e f�x�x 0 formatterted_time  ) m   g j.. �//  ]' o      �w�w 0 
error_time  % 010 l  n n�v23�v  2   # Prepare location message   3 �44 4 #   P r e p a r e   l o c a t i o n   m e s s a g e1 565 r   n 787 b   n }9:9 b   n y;<; b   n w=>= b   n s?@? m   n qAA �BB  [ b u n d l e r . s c p t :@ o   q r�u�u 0 _handler  > m   s vCC �DD  :< o   w x�t�t 0 line_num  : m   y |EE �FF  ]8 o      �s�s 0 	_location  6 GHG l  � ��rIJ�r  I  # Prepare level message   J �KK . #   P r e p a r e   l e v e l   m e s s a g eH LML r   � �NON b   � �PQP b   � �RSR m   � �TT �UU  [S o   � ��q�q 
0 _level  Q m   � �VV �WW  ]O o      �p�p 
0 _level  M XYX l  � ��oZ[�o  Z / )# Generate full error message for logging   [ �\\ R #   G e n e r a t e   f u l l   e r r o r   m e s s a g e   f o r   l o g g i n gY ]^] r   � �_`_ b   � �aba l  � �c�n�mc n  � �ded I   � ��lf�k�l 
0 joiner  f ghg J   � �ii jkj o   � ��j�j 0 log_time  k lml o   � ��i�i 0 	_location  m non o   � ��h�h 
0 _level  o p�gp o   � ��f�f 0 _message  �g  h q�eq 1   � ��d
�d 
spac�e  �k  e  f   � ��n  �m  b l  � �r�c�br I  � ��as�`
�a .sysontocTEXT       shors m   � ��_�_ 
�`  �c  �b  ` o      �^�^ 0 log_msg  ^ tut n  � �vwv I   � ��]x�\�] 0 write_to_file  x yzy o   � ��[�[ 0 log_msg  z {|{ n  � �}~} I   � ��Z�Y�X�Z 0 get_logfile  �Y  �X  ~  f   � �| �W m   � ��V
�V boovtrue�W  �\  w  f   � �u ��� l  � ��U���U  � < 6# Generate regular error message for returning to user   � ��� l #   G e n e r a t e   r e g u l a r   e r r o r   m e s s a g e   f o r   r e t u r n i n g   t o   u s e r� ��� r   � ���� b   � ���� b   � ���� b   � ���� b   � ���� b   � ���� b   � ���� o   � ��T�T 0 
error_time  � 1   � ��S
�S 
spac� o   � ��R�R 0 	_location  � 1   � ��Q
�Q 
spac� o   � ��P�P 
0 _level  � 1   � ��O
�O 
spac� o   � ��N�N 0 _message  � o      �M�M 0 	error_msg  � ��L� L   � ��� o   � ��K�K 0 	error_msg  �L  � ��� l     �J�I�H�J  �I  �H  � ��� l      �G���G  � #  ///
SUB-ACTION HANDLERS
///    � ��� :   / / / 
 S U B - A C T I O N   H A N D L E R S 
 / / /  � ��� l     �F�E�D�F  �E  �D  � ��� i   / 2��� I      �C�B�A�C 0 date_formatter  �B  �A  � k     ��� ��� l      �@���@  � � � Format current date and time into %Y-%m-%d %H:%M:%S string format.
	
	:returns: Formatted date-time stamp
	:rtype: ``string``
		
	   � ���   F o r m a t   c u r r e n t   d a t e   a n d   t i m e   i n t o   % Y - % m - % d   % H : % M : % S   s t r i n g   f o r m a t . 
 	 
 	 : r e t u r n s :   F o r m a t t e d   d a t e - t i m e   s t a m p 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	� ��� r     !��� I     �?�>�=
�? .misccurdldt    ��� null�>  �=  � K    
�� �<��
�< 
year� o    �;�; 0 y  � �:��
�: 
mnth� o    �9�9 0 m  � �8��7
�8 
day � o    �6�6 0 d  �7  � ��� r   " /��� c   " -��� l  " +��5�4� [   " +��� [   " )��� ]   " %��� o   " #�3�3 0 y  � m   # $�2�2'� ]   % (��� o   % &�1�1 0 m  � m   & '�0�0 d� o   ) *�/�/ 0 d  �5  �4  � m   + ,�.
�. 
TEXT� o      �-�- 0 date_num  � ��� r   0 _��� l  0 ]��,�+� b   0 ]��� b   0 M��� b   0 I��� b   0 =��� l  0 ;��*�)� n   0 ;��� 7  1 ;�(��
�( 
ctxt� m   5 7�'�' � m   8 :�&�& � o   0 1�%�% 0 date_num  �*  �)  � m   ; <�� ���  -� l  = H��$�#� n   = H��� 7  > H�"��
�" 
ctxt� m   B D�!�! � m   E G� �  � o   = >�� 0 date_num  �$  �#  � m   I L�� ���  -� l  M \���� n   M \��� 7  N \���
� 
ctxt� m   R V�� � m   W [�� � o   M N�� 0 date_num  �  �  �,  �+  � o      �� 0 formatterted_date  � ��� r   ` {��� c   ` y��� n   ` w��� 7  i w���
� 
citm� m   o q�� � m   r v����� l  ` i���� n   ` i��� 1   e i�
� 
tstr� l  ` e���� I  ` e���
� .misccurdldt    ��� null�  �  �  �  �  �  � m   w x�
� 
TEXT� o      �� 0 formatterted_time  � ��
� L   | ��� b   | ���� b   | ���� o   | }�	�	 0 formatterted_date  � 1   } ��
� 
spac� o   � ��� 0 formatterted_time  �
  � ��� l     ����  �  �  � ��� i   3 6��� I      ���� 0 	read_file  � ��� o      � �  0 target_file  �  �  � k     ��    l      ����   � � Read data from `target_file`.
	
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:returns: Data contained in `target_file`
	:rtype: ``string``
		
	    ��   R e a d   d a t a   f r o m   ` t a r g e t _ f i l e ` . 
 	 
 	 : p a r a m   t a r g e t _ f i l e :   F u l l   p a t h   t o   t h e   f i l e   t o   b e   w r i t t e n   t o 
 	 : t y p e   t a r g e t _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   D a t a   c o n t a i n e d   i n   ` t a r g e t _ f i l e ` 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	  I    ����
�� .rdwropenshor       file 4     ��
�� 
psxf o    ���� 0 target_file  ��   	
	 r   	  l  	 ���� I  	 ����
�� .rdwrread****        **** o   	 
���� 0 target_file  ��  ��  ��   o      ���� 0 	_contents  
  I   ����
�� .rdwrclosnull���     **** o    ���� 0 target_file  ��   �� L     o    ���� 0 	_contents  ��  �  l     ��������  ��  ��    i   7 : I      ������ 0 prepare_cmd   �� o      ���� 0 cmd  ��  ��   k       l      �� ��   � � Ensure shell `_cmd` is working from the proper directory.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:returns: ``string``

	     �!!�   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r   d i r e c t o r y . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r e t u r n s :   ` ` s t r i n g ` ` 
 
 	 "#" r     	$%$ n     &'& 1    ��
�� 
strq' l    (����( n    )*) I    �������� 0 pwd  ��  ��  *  f     ��  ��  % o      ���� 0 pwd  # +��+ L   
 ,, b   
 -.- b   
 /0/ b   
 121 m   
 33 �44  c d  2 o    ���� 0 pwd  0 m    55 �66  ;   b a s h  . o    ���� 0 cmd  ��   787 l     ��������  ��  ��  8 9:9 l     ��������  ��  ��  : ;<; l      ��=>��  = #  ///
IO HELPER FUNCTIONS
///    > �?? :   / / / 
 I O   H E L P E R   F U N C T I O N S 
 / / /  < @A@ l     ��������  ��  ��  A BCB i   ; >DED I      ��F���� 0 write_to_file  F GHG o      ���� 0 	this_data  H IJI o      ���� 0 target_file  J K��K o      ���� 0 append_data  ��  ��  E k     YLL MNM l      ��OP��  O�� Write or append `this_data` to `target_file`.
	
	:param this_data: The text to be written to the file
	:type this_data: ``string``
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:param append_data: Overwrite or append text to file?
	:type append_data: ``Boolean``
	:returns: Was the write successful?
	:rtype: ``Boolean``
		
	   P �QQ   W r i t e   o r   a p p e n d   ` t h i s _ d a t a `   t o   ` t a r g e t _ f i l e ` . 
 	 
 	 : p a r a m   t h i s _ d a t a :   T h e   t e x t   t o   b e   w r i t t e n   t o   t h e   f i l e 
 	 : t y p e   t h i s _ d a t a :   ` ` s t r i n g ` ` 
 	 : p a r a m   t a r g e t _ f i l e :   F u l l   p a t h   t o   t h e   f i l e   t o   b e   w r i t t e n   t o 
 	 : t y p e   t a r g e t _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : p a r a m   a p p e n d _ d a t a :   O v e r w r i t e   o r   a p p e n d   t e x t   t o   f i l e ? 
 	 : t y p e   a p p e n d _ d a t a :   ` ` B o o l e a n ` ` 
 	 : r e t u r n s :   W a s   t h e   w r i t e   s u c c e s s f u l ? 
 	 : r t y p e :   ` ` B o o l e a n ` ` 
 	 	 
 	N R��R Q     YSTUS k    :VV WXW r    YZY c    [\[ l   ]����] o    ���� 0 target_file  ��  ��  \ m    ��
�� 
TEXTZ l     ^����^ o      ���� 0 target_file  ��  ��  X _`_ r   	 aba I  	 ��cd
�� .rdwropenshor       filec 4   	 ��e
�� 
psxfe o    ���� 0 target_file  d ��f��
�� 
permf m    ��
�� boovtrue��  b l     g����g o      ���� 0 open_target_file  ��  ��  ` hih Z   'jk����j =   lml o    ���� 0 append_data  m m    ��
�� boovfalsk I   #��no
�� .rdwrseofnull���     ****n l   p����p o    ���� 0 open_target_file  ��  ��  o ��q��
�� 
set2q m    ����  ��  ��  ��  i rsr I  ( 1��tu
�� .rdwrwritnull���     ****t o   ( )���� 0 	this_data  u ��vw
�� 
refnv l  * +x����x o   * +���� 0 open_target_file  ��  ��  w ��y��
�� 
wraty m   , -��
�� rdwreof ��  s z{z I  2 7��|��
�� .rdwrclosnull���     ****| l  2 3}����} o   2 3���� 0 open_target_file  ��  ��  ��  { ~��~ L   8 : m   8 9��
�� boovtrue��  T R      ������
�� .ascrerr ****      � ****��  ��  U k   B Y�� ��� Q   B V����� I  E M�����
�� .rdwrclosnull���     ****� 4   E I���
�� 
file� o   G H���� 0 target_file  ��  � R      ������
�� .ascrerr ****      � ****��  ��  ��  � ���� L   W Y�� m   W X��
�� boovfals��  ��  C ��� l     ��������  ��  ��  � ��� l     ������  �  #    � ���  #  � ��� i   ? B��� I      �������� 0 pwd  ��  ��  � k     8�� ��� l      ������  � � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   � ���J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ��� r     ��� J     �� ��� n    ��� 1    ��
�� 
txdl� 1     ��
�� 
ascr� ���� m    �� ���  /��  � J      �� ��� o      ���� 0 astid ASTID� ���� n     ��� 1    ��
�� 
txdl� 1    ��
�� 
ascr��  � ��� r    /��� b    -��� l   +������ c    +��� n    )��� 7   )����
�� 
citm� m   # %���� � m   & (������� l   ���~� n    ��� 1    �}
�} 
psxp� l   ��|�{� I   �z��y
�z .earsffdralis        afdr�  f    �y  �|  �{  �  �~  � m   ) *�x
�x 
TEXT��  ��  � m   + ,�� ���  /� o      �w�w 	0 _path  � ��� r   0 5��� o   0 1�v�v 0 astid ASTID� n     ��� 1   2 4�u
�u 
txdl� 1   1 2�t
�t 
ascr� ��s� L   6 8�� o   6 7�r�r 	0 _path  �s  � ��� l     �q�p�o�q  �p  �o  � ��� i   C F��� I      �n��m�n 0 dirname  � ��l� o      �k�k 	0 _file  �l  �m  � k     2�� ��� l      �j���j  � � � Get name of directory containing `_file`.
	
	:param _file: Full path to existing file
	:type _file: ``string`` (POSIX path)
	:returns: Full path to `_file`'s parent directory
	:rtype: ``string`` (POSIX path)
		
	   � ����   G e t   n a m e   o f   d i r e c t o r y   c o n t a i n i n g   ` _ f i l e ` . 
 	 
 	 : p a r a m   _ f i l e :   F u l l   p a t h   t o   e x i s t i n g   f i l e 
 	 : t y p e   _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   F u l l   p a t h   t o   ` _ f i l e ` ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 	 
 	� ��� r     ��� J     �� ��� n    ��� 1    �i
�i 
txdl� 1     �h
�h 
ascr� ��g� m    �� ���  /�g  � J      �� ��� o      �f�f 0 astid ASTID� ��e� n     ��� 1    �d
�d 
txdl� 1    �c
�c 
ascr�e  � ��� r    )��� b    '��� l   %��b�a� c    %��� n    #��� 7   #�`��
�` 
citm� m    �_�_ � m     "�^�^��� o    �]�] 	0 _file  � m   # $�\
�\ 
TEXT�b  �a  � m   % &�� ���  /� o      �[�[ 	0 _path  � ��� r   * /��� o   * +�Z�Z 0 astid ASTID� n     ��� 1   , .�Y
�Y 
txdl� 1   + ,�X
�X 
ascr� ��W� L   0 2�� o   0 1�V�V 	0 _path  �W  � � � l     �U�T�S�U  �T  �S     i   G J I      �R�Q�R 0 	check_dir   �P o      �O�O 0 _folder  �P  �Q   k      	 l      �N
�N  
 � � Check if `_folder` exists, and if not create it and any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	    �"   C h e c k   i f   ` _ f o l d e r `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t   a n d   a n y   s u b - d i r e c t o r i e s . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ f o l d e r ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 		  Z     �M�L H      n     I    �K�J�K 0 folder_exists   �I o    �H�H 0 _folder  �I  �J    f      I  
 �G�F
�G .sysoexecTEXT���     TEXT b   
  m   
  �  m k d i r   - p   l   �E�D n     1    �C
�C 
strq o    �B�B 0 _folder  �E  �D  �F  �M  �L   �A L     o    �@�@ 0 _folder  �A    !  l     �?�>�=�?  �>  �=  ! "#" i   K N$%$ I      �<&�;�< 0 
check_file  & '�:' o      �9�9 	0 _path  �:  �;  % k     -(( )*) l      �8+,�8  + � � Check if `_path` exists, and if not create it and its directory tree.

	:returns: POSIX path to `_path`
	:rtype: ``string`` (POSIX path)

	   , �--   C h e c k   i f   ` _ p a t h `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t   a n d   i t s   d i r e c t o r y   t r e e . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ p a t h ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	* .�7. Z     -/0�6�5/ H     11 n    232 I    �44�3�4 0 file_exists  4 5�25 o    �1�1 	0 _path  �2  �3  3  f     0 k   
 )66 787 r   
 9:9 I   
 �0;�/�0 0 dirname  ; <�.< o    �-�- 	0 _path  �.  �/  : o      �,�, 0 _dir  8 =>= n   ?@? I    �+A�*�+ 0 	check_dir  A B�)B o    �(�( 0 _dir  �)  �*  @  f    > CDC I   �'E�&
�' .sysodelanull��� ��� nmbrE m    FF ?��������&  D G�%G I    )�$H�#
�$ .sysoexecTEXT���     TEXTH b     %IJI m     !KK �LL  t o u c h  J l  ! $M�"�!M n   ! $NON 1   " $� 
�  
strqO o   ! "�� 	0 _path  �"  �!  �#  �%  �6  �5  �7  # PQP l     ����  �  �  Q RSR l     �TU�  T , &#  handler to check if a folder exists   U �VV L #     h a n d l e r   t o   c h e c k   i f   a   f o l d e r   e x i s t sS WXW i   O RYZY I      �[�� 0 folder_exists  [ \�\ o      �� 0 _folder  �  �  Z k     ]] ^_^ l      �`a�  ` � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	   a �bb>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	_ cdc Z     ef��e n    ghg I    �i�� 0 path_exists  i j�j o    �� 0 _folder  �  �  h  f     f O   	 klk L    mm l   n��n =   opo n    qrq m    �
� 
pclsr l   s��s 4    �
t
�
 
ditmt o    �	�	 0 _folder  �  �  p m    �
� 
cfol�  �  l m   	 
uu�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �  �  d v�v L    ww m    �
� boovfals�  X xyx l     ����  �  �  y z{z l     �|}�  | ) ## handler to check if a file exists   } �~~ F #   h a n d l e r   t o   c h e c k   i f   a   f i l e   e x i s t s{ � i   S V��� I      ��� � 0 file_exists  � ���� o      ���� 	0 _file  ��  �   � k     �� ��� l      ������  � � � Return ``true`` if `_file` exists, else ``false``

	:param _file: Full path to file
	:type _file: ``string`` (POSIX path)
	:returns: ``Boolean``

	   � ���(   R e t u r n   ` ` t r u e ` `   i f   ` _ f i l e `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f i l e :   F u l l   p a t h   t o   f i l e 
 	 : t y p e   _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	� ��� Z     ������� n    ��� I    ������� 0 path_exists  � ���� o    ���� 	0 _file  ��  ��  �  f     � O   	 ��� L    �� l   ������ =   ��� n    ��� m    ��
�� 
pcls� l   ������ 4    ���
�� 
ditm� o    ���� 	0 _file  ��  ��  � m    ��
�� 
file��  ��  � m   	 
���                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��  � ���� L    �� m    ��
�� boovfals��  � ��� l     ��������  ��  ��  � ��� l     ������  � * $#  handler to check if a path exists   � ��� H #     h a n d l e r   t o   c h e c k   i f   a   p a t h   e x i s t s� ��� i   W Z��� I      ������� 0 path_exists  � ���� o      ���� 	0 _path  ��  ��  � k     Y�� ��� l      ������  � � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	   � ���D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	� ��� Z    ������� G     ��� =    ��� o     ���� 	0 _path  � m    ��
�� 
msng� n   ��� I    ������� 0 is_empty  � ���� o    ���� 	0 _path  ��  ��  �  f    � L    �� m    ��
�� boovfals��  ��  � ��� l   ��������  ��  ��  � ���� Q    Y���� k    O�� ��� Z   )������� =    ��� n    ��� m    ��
�� 
pcls� o    ���� 	0 _path  � m    ��
�� 
alis� L   # %�� m   # $��
�� boovtrue��  ��  � ���� Z   * O����� E   * -��� o   * +���� 	0 _path  � m   + ,�� ���  :� k   0 8�� ��� 4   0 5���
�� 
alis� o   2 3���� 	0 _path  � ���� L   6 8�� m   6 7��
�� boovtrue��  � ��� E   ; >��� o   ; <���� 	0 _path  � m   < =�� ���  /� ���� k   A J�� ��� c   A G��� 4   A E���
�� 
psxf� o   C D���� 	0 _path  � m   E F��
�� 
alis� ���� L   H J�� m   H I��
�� boovtrue��  ��  � L   M O�� m   M N��
�� boovfals��  � R      �����
�� .ascrerr ****      � ****� o      ���� 0 msg  ��  � L   W Y�� m   W X��
�� boovfals��  � ��� l     ��������  ��  ��  � ��� l      ������  � %  ///
TEXT HELPER FUNCTIONS
///    � ��� >   / / / 
 T E X T   H E L P E R   F U N C T I O N S 
 / / /  � ��� l     ��������  ��  ��  � ��� i   [ ^��� I      ������� 	0 split  � � � o      ���� 0 str    �� o      ���� 	0 delim  ��  ��  � k     3  l      ����   � � Split a string into a list

	:param str: A text string
	:type str: ``string``
	:param delim: Where to split `str` into pieces
	:type delim: ``string``
	:returns: the split list
	:rtype: ``list``

	    ��   S p l i t   a   s t r i n g   i n t o   a   l i s t 
 
 	 : p a r a m   s t r :   A   t e x t   s t r i n g 
 	 : t y p e   s t r :   ` ` s t r i n g ` ` 
 	 : p a r a m   d e l i m :   W h e r e   t o   s p l i t   ` s t r `   i n t o   p i e c e s 
 	 : t y p e   d e l i m :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t h e   s p l i t   l i s t 
 	 : r t y p e :   ` ` l i s t ` ` 
 
 	 	 q      

 ���� 	0 delim   ���� 0 str   ������ 0 astid ASTID��  	  r      n     1    ��
�� 
txdl 1     ��
�� 
ascr o      ���� 0 astid ASTID �� Q    3 k   	   r   	  o   	 
���� 	0 delim   n      1    ��
�� 
txdl 1   
 ��
�� 
ascr  r     !  n    "#" 2   ��
�� 
citm# o    ���� 0 str  ! o      ���� 0 str   $%$ r    &'& o    ���� 0 astid ASTID' n     ()( 1    ��
�� 
txdl) 1    ��
�� 
ascr% *��* l   +,-+ L    .. o    ���� 0 str  ,  > list   - �//  >   l i s t��   R      ��01
�� .ascrerr ****      � ****0 o      ���� 0 msg  1 ��2��
�� 
errn2 o      ���� 0 num  ��   k   % 333 454 r   % *676 o   % &���� 0 astid ASTID7 n     898 1   ' )��
�� 
txdl9 1   & '��
�� 
ascr5 :��: R   + 3��;<
�� .ascrerr ****      � ****; b   / 2=>= m   / 0?? �@@  C a n ' t   e x p l o d e :  > o   0 1���� 0 msg  < ��A��
�� 
errnA o   - .���� 0 num  ��  ��  ��  � BCB l     ��������  ��  ��  C DED l     ��FG��  F ! # format string � la Python   G �HH 6 #   f o r m a t   s t r i n g   �   l a   P y t h o nE IJI i   _ bKLK I      ��M���� 0 	formatter  M NON o      ���� 0 str  O P��P o      ���� 0 arg  ��  ��  L k     EQQ RSR l      ��TU��  T � � Replace `{}` in `str` with `arg`

	:param str: A text string with one instance of `{}`
	:type str: ``string``
	:param arg: The text to replace `{}`
	:type arg: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   U �VV�   R e p l a c e   ` { } `   i n   ` s t r `   w i t h   ` a r g ` 
 
 	 : p a r a m   s t r :   A   t e x t   s t r i n g   w i t h   o n e   i n s t a n c e   o f   ` { } ` 
 	 : t y p e   s t r :   ` ` s t r i n g ` ` 
 	 : p a r a m   a r g :   T h e   t e x t   t o   r e p l a c e   ` { } ` 
 	 : t y p e   a r g :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	S WXW q      YY ��Z�� 0 astid ASTIDZ ��[�� 0 str  [ ��\�� 0 arg  \ ������ 0 lst  ��  X ]^] r     _`_ n    aba 1    ��
�� 
txdlb 1     ��
�� 
ascr` o      �� 0 astid ASTID^ c�~c Q    Edefd k   	 /gg hih P   	 &jk�}j k    %ll mnm r    opo m    qq �rr  { }p n     sts 1    �|
�| 
txdlt 1    �{
�{ 
ascrn uvu r    wxw n    yzy 2    �z
�z 
citmz o    �y�y 0 str  x o      �x�x 0 lst  v {|{ r    }~} o    �w�w 0 arg  ~ n     � 1    �v
�v 
txdl� 1    �u
�u 
ascr| ��t� r     %��� c     #��� o     !�s�s 0 lst  � m   ! "�r
�r 
TEXT� o      �q�q 0 str  �t  k �p�o
�p conscase�o  �}  i ��� r   ' ,��� o   ' (�n�n 0 astid ASTID� n     ��� 1   ) +�m
�m 
txdl� 1   ( )�l
�l 
ascr� ��k� L   - /�� o   - .�j�j 0 str  �k  e R      �i��
�i .ascrerr ****      � ****� o      �h�h 0 msg  � �g��f
�g 
errn� o      �e�e 0 num  �f  f k   7 E�� ��� r   7 <��� o   7 8�d�d 0 astid ASTID� n     ��� 1   9 ;�c
�c 
txdl� 1   8 9�b
�b 
ascr� ��a� R   = E�`��
�` .ascrerr ****      � ****� b   A D��� m   A B�� ��� * C a n ' t   r e p l a c e S t r i n g :  � o   B C�_�_ 0 msg  � �^��]
�^ 
errn� o   ? @�\�\ 0 num  �]  �a  �~  J ��� l     �[�Z�Y�[  �Z  �Y  � ��� l     �X���X  � 0 *# removes white space surrounding a string   � ��� T #   r e m o v e s   w h i t e   s p a c e   s u r r o u n d i n g   a   s t r i n g� ��� i   c f��� I      �W��V�W 0 trim  � ��U� o      �T�T 0 _str  �U  �V  � k     ��� ��� l      �S���S  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   � ���4   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	� ��� Z     ���R�Q� G     ��� G     ��� >    ��� n     ��� m    �P
�P 
pcls� o     �O�O 0 _str  � m    �N
�N 
ctxt� >   ��� n    ��� m   	 �M
�M 
pcls� o    	�L�L 0 _str  � m    �K
�K 
TEXT� =   ��� o    �J�J 0 _str  � m    �I
�I 
msng� L    �� o    �H�H 0 _str  �R  �Q  � ��� Z  ! -���G�F� =  ! $��� o   ! "�E�E 0 _str  � m   " #�� ���  � L   ' )�� o   ' (�D�D 0 _str  �G  �F  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D�C��
�C 
cobj� m   > @�B�B � m   A C�A�A��� o   9 :�@�@ 0 _str  � m   D E�?
�? 
ctxt� o      �>�> 0 _str  � R      �=��<
�= .ascrerr ****      � ****� o      �;�; 0 msg  �<  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�:�: 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n�9��
�9 
cobj� m   h j�8�8 � m   k m�7�7��� o   c d�6�6 0 _str  � m   n o�5
�5 
ctxt� o      �4�4 0 _str  � R      �3�2�1
�3 .ascrerr ****      � ****�2  �1  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�0�0 0 _str  � m   ] ^�� ���   � ��/� L   � ��� o   � ��.�. 0 _str  �/  � ��� l     �-�,�+�-  �,  �+  � 	 		  i   g j			 I      �*	�)�* 
0 joiner  	 			 o      �(�( 
0 pieces  	 	�'	 o      �&�& 	0 delim  �'  �)  	 k     3		 			
		 l      �%		�%  	 � Join list of `pieces` into a string delimted by `delim`.

	:param pieces: A list of objects
	:type pieces: ``list``
	:param delim: The text item by which to join the list items
	:type delim: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   	 �		�   J o i n   l i s t   o f   ` p i e c e s `   i n t o   a   s t r i n g   d e l i m t e d   b y   ` d e l i m ` . 
 
 	 : p a r a m   p i e c e s :   A   l i s t   o f   o b j e c t s 
 	 : t y p e   p i e c e s :   ` ` l i s t ` ` 
 	 : p a r a m   d e l i m :   T h e   t e x t   i t e m   b y   w h i c h   t o   j o i n   t h e   l i s t   i t e m s 
 	 : t y p e   d e l i m :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 		
 			 q      		 �$	�$ 	0 delim  	 �#	�# 
0 pieces  	 �"�!�" 0 astid ASTID�!  	 			 r     			 n    			 1    � 
�  
txdl	 1     �
� 
ascr	 o      �� 0 astid ASTID	 	�	 Q    3				 k   	 		 			 r   	 	 	!	  o   	 
�� 	0 delim  	! n     	"	#	" 1    �
� 
txdl	# 1   
 �
� 
ascr	 	$	%	$ r    	&	'	& b    	(	)	( m    	*	* �	+	+  	) o    �� 
0 pieces  	' o      �� 
0 pieces  	% 	,	-	, r    	.	/	. o    �� 0 astid ASTID	/ n     	0	1	0 1    �
� 
txdl	1 1    �
� 
ascr	- 	2�	2 l   	3	4	5	3 L    	6	6 o    �� 
0 pieces  	4  > text   	5 �	7	7  >   t e x t�  	 R      �	8	9
� .ascrerr ****      � ****	8 o      �� 0 emsg  	9 �	:�
� 
errn	: o      �� 0 enum eNum�  	 k   % 3	;	; 	<	=	< r   % *	>	?	> o   % &�� 0 astid ASTID	? n     	@	A	@ 1   ' )�
� 
txdl	A 1   & '�
� 
ascr	= 	B�
	B R   + 3�		C	D
�	 .ascrerr ****      � ****	C b   / 2	E	F	E m   / 0	G	G �	H	H  C a n ' t   i m p l o d e :  	F o   0 1�� 0 emsg  	D �	I�
� 
errn	I o   - .�� 0 enum eNum�  �
  �  	 	J	K	J l     ����  �  �  	K 	L	M	L l      �	N	O�  	N , & ///
LOWER LEVEL HELPER FUNCTIONS
///    	O �	P	P L   / / / 
 L O W E R   L E V E L   H E L P E R   F U N C T I O N S 
 / / /  	M 	Q	R	Q l     � �����   ��  ��  	R 	S	T	S l     ��	U	V��  	U " # checks if a value is empty   	V �	W	W 8 #   c h e c k s   i f   a   v a l u e   i s   e m p t y	T 	X��	X i   k n	Y	Z	Y I      ��	[���� 0 is_empty  	[ 	\��	\ o      ���� 0 _obj  ��  ��  	Z k     (	]	] 	^	_	^ l      ��	`	a��  	` � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:rtype: ``Boolean``
		
	   	a �	b	b   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r t y p e :   ` ` B o o l e a n ` ` 
 	 	 
 		_ 	c	d	c Z    	e	f����	e E     	g	h	g J     	i	i 	j	k	j m     ��
�� boovtrue	k 	l��	l m    ��
�� boovfals��  	h o    ���� 0 _obj  	f L   	 	m	m m   	 
��
�� boovfals��  ��  	d 	n	o	n Z   	p	q����	p =   	r	s	r o    ���� 0 _obj  	s m    ��
�� 
msng	q L    	t	t m    ��
�� boovtrue��  ��  	o 	u��	u L    (	v	v =   '	w	x	w n    %	y	z	y 1   # %��
�� 
leng	z l   #	{����	{ n   #	|	}	| I    #��	~���� 0 trim  	~ 	��	 o    ���� 0 _obj  ��  ��  	}  f    ��  ��  	x m   % &����  ��  ��       ��	� 	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	���  	� ���������������������������������������������������������� "0 bundler_version BUNDLER_VERSION�� 0 get_bundler_dir  �� 0 get_data_dir  �� 0 get_as_bundler  �� 0 
get_as_dir  �� 0 get_utils_dir  �� 0 get_icons_dir  �� 0 get_logfile  �� 0 library  �� 0 utility  �� 0 icon  �� 
0 logger  �� 0 date_formatter  �� 0 	read_file  �� 0 prepare_cmd  �� 0 write_to_file  �� 0 pwd  �� 0 dirname  �� 0 	check_dir  �� 0 
check_file  �� 0 folder_exists  �� 0 file_exists  �� 0 path_exists  �� 	0 split  �� 0 	formatter  �� 0 trim  �� 
0 joiner  �� 0 is_empty  	� ��  ����	�	����� 0 get_bundler_dir  ��  ��  	�  	� ���������� -
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %	� �� 9����	�	����� 0 get_data_dir  ��  ��  	�  	� �� @�� 0 get_bundler_dir  �� 	)j+  �%	� �� L����	�	����� 0 get_as_bundler  ��  ��  	�  	� �� S�� 0 get_bundler_dir  �� 	)j+  �%	� �� _����	�	����� 0 
get_as_dir  ��  ��  	�  	� �� f�� 0 get_data_dir  �� 	)j+  �%	� �� r����	�	����� 0 get_utils_dir  ��  ��  	�  	� �� y�� 0 get_data_dir  �� 	)j+  �%	� �� �����	�	����� 0 get_icons_dir  ��  ��  	�  	� �� ��� 0 get_data_dir  �� 	)j+  �%	� �� �����	�	����� 0 get_logfile  ��  ��  	� ������ 0 unformatted_path  �� "0 bundler_logfile BUNDLER_LOGFILE	� �� ����� 0 get_data_dir  �� 0 	formatter  �� )j+  �%E�O)�b   l+ E�	� �� �����	�	����� 0 library  �� ��	��� 	�  �������� 	0 _name  �� 0 _version  �� 0 
_json_path  ��  	� �������������������������� 	0 _name  �� 0 _version  �� 0 
_json_path  �� 	0 _json  �� 0 _library  �� 0 bash_bundlet  �� 0 bash_bundlet_cmd  �� 0 cmd  �� 0 	full_path  �� 0 	error_msg  �� 0 invoke_file  �� 0 invoke_path  	� -�� � ��� �����&��������~6�}�|W�{�z�ynrv~�x�w�����v������u��� 0 is_empty  �� 0 
get_as_dir  �� 
0 joiner  �� 0 folder_exists  �� 0 	formatter  �� �� 
0 logger  � 0 get_as_bundler  �~ 0 dirname  �} 0 file_exists  
�| 
strq�{ 
�z 
spac�y 0 prepare_cmd  
�x .sysoexecTEXT���     TEXT
�w .sysoloadscpt        file
�v 
errn�u 0 	read_file  ��J)�k+   �E�Y hO)�k+   �E�Y hO))j+ ��mv�l+ E�O)�k+ f  �)���)�l+ �+ O))j+ k+ a %E�O)�k+ e  R�a ,E�O)�a ���a v_ l+ E�O)�k+ E�O)a a a )a �l+ �+ O�j E�O�j Y $)a a a )a  �l+ �+ E�O)a !kl�Y k)a "a #a $)a %�l+ �+ O�a &%E�O)�k+ e  )�k+ 'E�O�a (%�%E�O�j Y $)a )a *a +)a ,�l+ �+ E�O)a !kl�	� �t%�s�r	�	��q�t 0 utility  �s �p	��p 	�  �o�n�m�o 	0 _name  �n 0 _version  �m 0 
_json_path  �r  	� �l�k�j�i�h�g�f�e�d�c�b�a�l 	0 _name  �k 0 _version  �j 0 
_json_path  �i 	0 _json  �h 0 _utility  �g 0 bash_bundlet  �f 0 bash_bundlet_cmd  �e 0 cmd  �d 0 	full_path  �c 0 	error_msg  �b 0 invoke_file  �a 0 invoke_path  	� ,�`AM�_f�^�]����\�[�Z�Y�X��W�V��U�T�S�����R� �Q%)-5C�Pesw{��` 0 is_empty  �_ 0 get_utils_dir  �^ 
0 joiner  �] 0 folder_exists  �\ 0 	formatter  �[ �Z 
0 logger  �Y 0 get_as_bundler  �X 0 dirname  �W 0 file_exists  
�V 
strq�U 
�T 
spac�S 0 prepare_cmd  
�R .sysoexecTEXT���     TEXT
�Q 
errn�P 0 	read_file  �qF)�k+   �E�Y hO)�k+   �E�Y hO))j+ ��mv�l+ E�O)�k+ f  �)���)�l+ �+ O))j+ k+ a %E�O)�k+ e  N�a ,E�O)�a ���a v_ l+ E�O)�k+ E�O)a a a )a �l+ �+ O�j E�O�Y &)a a a )a �l+ �+ E�O)a  kl�OPY i)a !a "a #)a $�l+ �+ O�a %%E�O)�k+ e  )�k+ &E�O�a '%�%E�O�Y &)a (a )a *)a +�l+ �+ E�O)a  kl�OP	� �O��N�M	�	��L�O 0 icon  �N �K	��K 	�  �J�I�H�G�J 	0 _font  �I 	0 _name  �H 
0 _color  �G 
0 _alter  �M  	� 
�F�E�D�C�B�A�@�?�>�=�F 	0 _font  �E 	0 _name  �D 
0 _color  �C 
0 _alter  �B 	0 _icon  �A 0 bash_bundlet  �@ 0 bash_bundlet_cmd  �? 0 cmd  �> 0 	full_path  �= 0 	error_msg  	� #�<��;�:��9�8��7�6�5�4�3�2?�1�0�/X\`h�.z~���-����< 0 is_empty  �; 0 get_icons_dir  �: �9 
0 joiner  �8 0 folder_exists  �7 0 	formatter  �6 
0 logger  �5 0 get_as_bundler  �4 0 dirname  �3 0 file_exists  
�2 
strq�1 
�0 
spac�/ 0 prepare_cmd  
�. .sysoexecTEXT���     TEXT
�- 
errn�L)�k+   �E�O)�k+   eE�Y hY hO)�k+   fE�Y hO))j+ ����v�l+ E�O)�k+ f  �)���)�l+ �+ O))j+ k+ �%E�O)�k+ e  L�a ,E�O)�a ����a v_ l+ E�O)�k+ E�O)a a a )a �l+ �+ O�j E�Y $)a a a )a �l+ �+ E�O)a kl�Y )a  a !)a "�l+ m+ O�	� �,��+�*	�	��)�, 
0 logger  �+ �(	��( 	�  �'�&�%�$�' 0 _handler  �& 0 line_num  �% 
0 _level  �$ 0 _message  �*  	� 
�#�"�!� �������# 0 _handler  �" 0 line_num  �! 
0 _level  �  0 _message  � 0 log_time  � 0 formatterted_time  � 0 
error_time  � 0 	_location  � 0 log_msg  � 0 	error_msg  	� ��������������,.ACETV���
�	��� 0 get_logfile  � 0 
check_file  �  �  � 0 get_data_dir  � 0 	formatter  
� .sysodelanull��� ��� nmbr� 0 date_formatter  
� .misccurdldt    ��� null
� 
tstr
� 
citm���
� 
TEXT� 
� 
spac�
 
0 joiner  �	 

� .sysontocTEXT       shor� 0 write_to_file  �) � ))j+  k+ W )X  ))j+ �%b   l+ )j+  FO))j+  k+ O�j O�)j+ 
%�%E�O*j �,[�\[Zk\Z�2a &E�Oa �%a %E�Oa �%a %�%a %E�Oa �%a %E�O)����a v_ l+ a j %E�O)�)j+  em+ O�_ %�%_ %�%_ %�%E�O�	� ����	�	��� 0 date_formatter  �  �  	� ��� ������� 0 y  � 0 m  �  0 d  �� 0 date_num  �� 0 formatterted_date  �� 0 formatterted_time  	� ��������������������������������������������
�� 
Krtn
�� 
year�� 0 y  
�� 
mnth�� 0 m  
�� 
day �� 0 d  �� 
�� .misccurdldt    ��� null��'�� d
�� 
TEXT
�� 
ctxt�� �� �� �� 
�� 
tstr
�� 
citm����
�� 
spac� �*��������l E[�,E�Z[�,E�Z[�,E�ZO�� �� ��&E�O�[�\[Zk\Z�2�%�[�\[Z�\Z�2%a %�[�\[Za \Za 2%E�O*j a ,[a \[Zk\Za 2�&E�O�_ %�%	� �������	�	����� 0 	read_file  �� ��	��� 	�  ���� 0 target_file  ��  	� ������ 0 target_file  �� 0 	_contents  	� ��������
�� 
psxf
�� .rdwropenshor       file
�� .rdwrread****        ****
�� .rdwrclosnull���     ****�� *�/j O�j E�O�j O�	� ������	�	����� 0 prepare_cmd  �� ��	��� 	�  ���� 0 cmd  ��  	� ������ 0 cmd  �� 0 pwd  	� ����35�� 0 pwd  
�� 
strq�� )j+  �,E�O�%�%�%	� ��E����	�	����� 0 write_to_file  �� ��	��� 	�  �������� 0 	this_data  �� 0 target_file  �� 0 append_data  ��  	� ���������� 0 	this_data  �� 0 target_file  �� 0 append_data  �� 0 open_target_file  	� ������������������������������
�� 
TEXT
�� 
psxf
�� 
perm
�� .rdwropenshor       file
�� 
set2
�� .rdwrseofnull���     ****
�� 
refn
�� 
wrat
�� rdwreof �� 
�� .rdwrwritnull���     ****
�� .rdwrclosnull���     ****��  ��  
�� 
file�� Z <��&E�O*�/�el E�O�f  ��jl Y hO����� 
O�j OeW X   *�/j W X  hOf	� �������	�	����� 0 pwd  ��  ��  	� ������ 0 astid ASTID�� 	0 _path  	� 
������������������
�� 
ascr
�� 
txdl
�� 
cobj
�� .earsffdralis        afdr
�� 
psxp
�� 
citm����
�� 
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�	� �������	�	����� 0 dirname  �� ��	��� 	�  ���� 	0 _file  ��  	� �������� 	0 _file  �� 0 astid ASTID�� 	0 _path  	� ��������������
�� 
ascr
�� 
txdl
�� 
cobj
�� 
citm����
�� 
TEXT�� 3��,�lvE[�k/E�Z[�l/��,FZO�[�\[Zk\Z�2�&�%E�O���,FO�	� ������	�	����� 0 	check_dir  �� ��	��� 	�  ���� 0 _folder  ��  	� ���� 0 _folder  	� �������� 0 folder_exists  
�� 
strq
�� .sysoexecTEXT���     TEXT�� )�k+   ��,%j Y hO�	� ��%����	�	����� 0 
check_file  �� ��	��� 	�  ���� 	0 _path  ��  	� ������ 	0 _path  �� 0 _dir  	� ������F��K������ 0 file_exists  �� 0 dirname  �� 0 	check_dir  
�� .sysodelanull��� ��� nmbr
�� 
strq
�� .sysoexecTEXT���     TEXT�� .)�k+   $*�k+ E�O)�k+ O�j O��,%j Y h	� ��Z���	�	��~�� 0 folder_exists  �� �}	��} 	�  �|�| 0 _folder  �  	� �{�{ 0 _folder  	� �zu�y�x�w�z 0 path_exists  
�y 
ditm
�x 
pcls
�w 
cfol�~ )�k+   � *�/�,� UY hOf	� �v��u�t	�	��s�v 0 file_exists  �u �r	��r 	�  �q�q 	0 _file  �t  	� �p�p 	0 _file  	� �o��n�m�l�o 0 path_exists  
�n 
ditm
�m 
pcls
�l 
file�s )�k+   � *�/�,� UY hOf	� �k��j�i	�	��h�k 0 path_exists  �j �g	��g 	�  �f�f 	0 _path  �i  	� �e�d�e 	0 _path  �d 0 msg  	� 
�c�b�a�`�_���^�]�\
�c 
msng�b 0 is_empty  
�a 
bool
�` 
pcls
�_ 
alis
�^ 
psxf�] 0 msg  �\  �h Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f	� �[��Z�Y	�	��X�[ 	0 split  �Z �W	��W 	�  �V�U�V 0 str  �U 	0 delim  �Y  	� �T�S�R�Q�P�T 0 str  �S 	0 delim  �R 0 astid ASTID�Q 0 msg  �P 0 num  	� �O�N�M�L	��K?
�O 
ascr
�N 
txdl
�M 
citm�L 0 msg  	� �J�I�H
�J 
errn�I 0 num  �H  
�K 
errn�X 4��,E�O ���,FO��-E�O���,FO�W X  ���,FO)�l�%	� �GL�F�E	�	��D�G 0 	formatter  �F �C	��C 	�  �B�A�B 0 str  �A 0 arg  �E  	� �@�?�>�=�<�;�@ 0 str  �? 0 arg  �> 0 astid ASTID�= 0 lst  �< 0 msg  �; 0 num  	� 
�:�9kq�8�7�6	��5�
�: 
ascr
�9 
txdl
�8 
citm
�7 
TEXT�6 0 msg  	� �4�3�2
�4 
errn�3 0 num  �2  
�5 
errn�D F��,E�O +�g ���,FO��-E�O���,FO��&E�VO���,FO�W X  ���,FO)�l�%	� �1��0�/	�	��.�1 0 trim  �0 �-	��- 	�  �,�, 0 _str  �/  	� �+�*�+ 0 _str  �* 0 msg  	� �)�(�'�&�%���$�#�"���!� �
�) 
pcls
�( 
ctxt
�' 
TEXT
�& 
bool
�% 
msng
�$ 
cobj�# 0 msg  �"  �!���   �. ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O�	� �	��	�	��� 
0 joiner  � �	�� 	�  ��� 
0 pieces  � 	0 delim  �  	� ������ 
0 pieces  � 	0 delim  � 0 astid ASTID� 0 emsg  � 0 enum eNum	� ��	*�	��	G
� 
ascr
� 
txdl� 0 emsg  	� ���
� 
errn� 0 enum eNum�  
� 
errn� 4��,E�O ���,FO�%E�O���,FO�W X  ���,FO)�l�%	� �	Z��
	�	��	� 0 is_empty  � �	�� 	�  �� 0 _obj  �
  	� �� 0 _obj  	� ���
� 
msng� 0 trim  
� 
leng�	 )eflv� fY hO��  eY hO)�k+ �,j ascr  ��ޭ