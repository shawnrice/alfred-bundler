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
_json_path  ��  ��   � k    7 � �  � � � l      �� � ���   ���  Get path to specified AppleScript library, installing it first if necessary.

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
get_as_dir  �r  �q   �  f   # $ �  � � � o   ( )�p�p 	0 _name   �  ��o � o   ) *�n�n 0 _version  �o   �  ��m � m   , - � � � � �  /�m  �t   �  f   " # � o      �l�l 0 _library   �  ��k � Z   47 �j  =   4 < n  4 : I   5 :�i�h�i 0 folder_exists   �g o   5 6�f�f 0 _library  �g  �h    f   4 5 m   : ;�e
�e boovfals k   ? �		 

 l  ? ?�d�d   * $# if utility isn't already installed    � H #   i f   u t i l i t y   i s n ' t   a l r e a d y   i n s t a l l e d  r   ? M b   ? K l  ? I�c�b n  ? I I   @ I�a�`�a 0 dirname   �_ n  @ E I   A E�^�]�\�^ 0 get_as_bundler  �]  �\    f   @ A�_  �`    f   ? @�c  �b   m   I J � 4 b u n d l e t s / a l f r e d . b u n d l e r . s h o      �[�[ 0 bash_bundlet   �Z Z   N � �Y! =   N V"#" n  N T$%$ I   O T�X&�W�X 0 file_exists  & '�V' o   O P�U�U 0 bash_bundlet  �V  �W  %  f   N O# m   T U�T
�T boovtrue  k   Y �(( )*) r   Y ^+,+ n   Y \-.- 1   Z \�S
�S 
strq. o   Y Z�R�R 0 bash_bundlet  , o      �Q�Q 0 bash_bundlet_cmd  * /0/ r   _ n121 n  _ l343 I   ` l�P5�O�P 
0 joiner  5 676 J   ` g88 9:9 o   ` a�N�N 0 bash_bundlet_cmd  : ;<; m   a b== �>>  a p p l e s c r i p t< ?@? o   b c�M�M 	0 _name  @ ABA o   c d�L�L 0 _version  B C�KC o   d e�J�J 0 
_json_path  �K  7 D�ID 1   g h�H
�H 
spac�I  �O  4  f   _ `2 o      �G�G 0 cmd  0 EFE r   o wGHG n  o uIJI I   p u�FK�E�F 0 prepare_cmd  K L�DL o   p q�C�C 0 cmd  �D  �E  J  f   o pH o      �B�B 0 cmd  F MNM n  x �OPO I   y ��AQ�@�A 
0 logger  Q RSR m   y |TT �UU  l i b r a r yS VWV m   | XX �YY  8 9W Z[Z m    �\\ �]]  I N F O[ ^�?^ n  � �_`_ I   � ��>a�=�> 0 	formatter  a bcb m   � �dd �ee < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . .c f�<f o   � ��;�; 0 cmd  �<  �=  `  f   � ��?  �@  P  f   x yN ghg r   � �iji l  � �k�:�9k I  � ��8l�7
�8 .sysoexecTEXT���     TEXTl o   � ��6�6 0 cmd  �7  �:  �9  j o      �5�5 0 	full_path  h m�4m L   � �nn I  � ��3o�2
�3 .sysoloadscpt        fileo o   � ��1�1 0 	full_path  �2  �4  �Y  ! k   � �pp qrq r   � �sts n  � �uvu I   � ��0w�/�0 
0 logger  w xyx m   � �zz �{{  l i b r a r yy |}| m   � �~~ �  9 3} ��� m   � ��� ��� 
 E R R O R� ��.� n  � ���� I   � ��-��,�- 0 	formatter  � ��� m   � ��� ��� T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t .� ��+� o   � ��*�* 0 bash_bundlet  �+  �,  �  f   � ��.  �/  v  f   � �t o      �)�) 0 	error_msg  r ��(� R   � ��'��
�' .ascrerr ****      � ****� o   � ��&�& 0 	error_msg  � �%��$
�% 
errn� m   � ��#�# �$  �(  �Z  �j   k   �7�� ��� l  � ��"���"  � ' !# if utility is already installed   � ��� B #   i f   u t i l i t y   i s   a l r e a d y   i n s t a l l e d� ��� n  � ���� I   � ��!�� �! 
0 logger  � ��� m   � ��� ���  l i b r a r y� ��� m   � ��� ���  9 8� ��� m   � ��� ���  I N F O� ��� n  � ���� I   � ����� 0 	formatter  � ��� m   � ��� ��� 0 L i b r a r y   a t   ` { } `   f o u n d . . .� ��� o   � ��� 0 _library  �  �  �  f   � ��  �   �  f   � �� ��� l  � �����  � " # read utilities invoke file   � ��� 8 #   r e a d   u t i l i t i e s   i n v o k e   f i l e� ��� r   � ���� b   � ���� o   � ��� 0 _library  � m   � ��� ���  / i n v o k e� o      �� 0 invoke_file  � ��� Z   �7����� =   � ���� n  � ���� I   � ����� 0 file_exists  � ��� o   � ��� 0 invoke_file  �  �  �  f   � �� m   � ��
� boovtrue� k   ��� ��� r   � ���� n  � ���� I   � ����� 0 	read_file  � ��� o   � ��� 0 invoke_file  �  �  �  f   � �� o      �� 0 invoke_path  � ��� l   ����  � - '# combine utility path with invoke path   � ��� N #   c o m b i n e   u t i l i t y   p a t h   w i t h   i n v o k e   p a t h� ��� r   	��� b   ��� b   ��� o   �
�
 0 _library  � m  �� ���  /� o  �	�	 0 invoke_path  � o      �� 0 	full_path  � ��� L  
�� I 
���
� .sysoloadscpt        file� o  
�� 0 	full_path  �  �  �  � k  7�� ��� r  .��� n ,��� I  ,���� 
0 logger  � ��� m  �� ���  l i b r a r y� ��� m  �� ���  1 0 7� ��� m  �� ��� 
 E R R O R� ��� n &��� I  &� ����  0 	formatter  � ��� m  !�� ��� R I n t e r n a l   i n v o k e   f i l e   ` { } `   d o e s   n o t   e x i s t .� ���� o  !"���� 0 invoke_file  ��  ��  �  f  �  �  �  f  � o      ���� 0 	error_msg  �  ��  R  /7��
�� .ascrerr ****      � **** o  56���� 0 	error_msg   ����
�� 
errn m  34���� ��  ��  �  �k   �  l     ��������  ��  ��    l     ��������  ��  ��   	 i   # &

 I      ������ 0 utility    o      ���� 	0 _name    o      ���� 0 _version   �� o      ���� 0 
_json_path  ��  ��   k    3  l      ����  	  Get path to specified utility or asset, installing it first if necessary.

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

	    �     G e t   p a t h   t o   s p e c i f i e d   u t i l i t y   o r   a s s e t ,   i n s t a l l i n g   i t   f i r s t   i f   n e c e s s a r y . 
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
 	  l     ����   : 4# partial support for "optional" args in Applescript    � h #   p a r t i a l   s u p p o r t   f o r   " o p t i o n a l "   a r g s   i n   A p p l e s c r i p t  Z      ���� n    !"! I    ��#���� 0 is_empty  # $��$ o    ���� 0 _version  ��  ��  "  f       r   	 %&% m   	 
'' �((  l a t e s t& o      ���� 0 _version  ��  ��   )*) Z    !+,����+ n   -.- I    ��/���� 0 is_empty  / 0��0 o    ���� 0 
_json_path  ��  ��  .  f    , r    121 m    33 �44  2 o      ���� 	0 _json  ��  ��  * 565 l  " "��78��  7   # path to specific utility   8 �99 4 #   p a t h   t o   s p e c i f i c   u t i l i t y6 :;: r   " 3<=< n  " 1>?> I   # 1��@���� 
0 joiner  @ ABA J   # ,CC DED n  # (FGF I   $ (�������� 0 get_utils_dir  ��  ��  G  f   # $E HIH o   ( )���� 	0 _name  I J��J o   ) *���� 0 _version  ��  B K��K m   , -LL �MM  /��  ��  ?  f   " #= o      ���� 0 _utility  ; N��N Z   43OP��QO =   4 <RSR n  4 :TUT I   5 :��V���� 0 folder_exists  V W��W o   5 6���� 0 _utility  ��  ��  U  f   4 5S m   : ;��
�� boovfalsP k   ? �XX YZY l  ? ?��[\��  [ * $# if utility isn't already installed   \ �]] H #   i f   u t i l i t y   i s n ' t   a l r e a d y   i n s t a l l e dZ ^_^ r   ? M`a` b   ? Kbcb l  ? Id����d n  ? Iefe I   @ I��g���� 0 dirname  g h��h n  @ Eiji I   A E�������� 0 get_as_bundler  ��  ��  j  f   @ A��  ��  f  f   ? @��  ��  c m   I Jkk �ll 4 b u n d l e t s / a l f r e d . b u n d l e r . s ha o      ���� 0 bash_bundlet  _ m��m Z   N �no��pn =   N Vqrq n  N Tsts I   O T��u���� 0 file_exists  u v��v o   O P���� 0 bash_bundlet  ��  ��  t  f   N Or m   T U��
�� boovtrueo k   Y �ww xyx r   Y ^z{z n   Y \|}| 1   Z \��
�� 
strq} o   Y Z���� 0 bash_bundlet  { o      ���� 0 bash_bundlet_cmd  y ~~ r   _ n��� n  _ l��� I   ` l������� 
0 joiner  � ��� J   ` g�� ��� o   ` a���� 0 bash_bundlet_cmd  � ��� m   a b�� ���  u t i l i t y� ��� o   b c���� 	0 _name  � ��� o   c d���� 0 _version  � ���� o   d e���� 0 
_json_path  ��  � ���� 1   g h��
�� 
spac��  ��  �  f   _ `� o      ���� 0 cmd   ��� r   o w��� n  o u��� I   p u������� 0 prepare_cmd  � ���� o   p q���� 0 cmd  ��  ��  �  f   o p� o      ���� 0 cmd  � ��� n  x ���� I   y �������� 
0 logger  � ��� m   y |�� ���  u t i l i t y� ��� m   | �� ���  1 5 6� ��� m    ��� ���  I N F O� ���� n  � ���� I   � �������� 0 	formatter  � ��� m   � ��� ��� < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . .� ���� o   � ����� 0 cmd  ��  ��  �  f   � ���  ��  �  f   x y� ��� r   � ���� l  � ������� I  � ������
�� .sysoexecTEXT���     TEXT� o   � ����� 0 cmd  ��  ��  ��  � o      ���� 0 	full_path  � ���� L   � ��� o   � ����� 0 	full_path  ��  ��  p k   � ��� ��� r   � ���� n  � ���� I   � �������� 
0 logger  � ��� m   � ��� ���  u t i l i t y� ��� m   � ��� ���  1 6 0� ��� m   � ��� ��� 
 E R R O R� ���� n  � ���� I   � �������� 0 	formatter  � ��� m   � ��� ��� T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t .� ���� o   � ����� 0 bash_bundlet  ��  ��  �  f   � ���  ��  �  f   � �� o      ���� 0 	error_msg  � ��� R   � �����
�� .ascrerr ****      � ****� o   � ����� 0 	error_msg  � �����
�� 
errn� m   � ����� ��  � ���� l  � �������  � / )##TODO: need a stable error number schema   � ��� R # # T O D O :   n e e d   a   s t a b l e   e r r o r   n u m b e r   s c h e m a��  ��  ��  Q k   �3�� ��� l  � �������  � ' !# if utility is already installed   � ��� B #   i f   u t i l i t y   i s   a l r e a d y   i n s t a l l e d� ��� n  � ���� I   � �������� 
0 logger  � ��� m   � ��� ���  u t i l i t y� ��� m   � ��� ���  1 6 6� ��� m   � ��� ���  I N F O� ���� n  � ���� I   � �������� 0 	formatter  � � � m   � � � 0 U t i l i t y   a t   ` { } `   f o u n d . . .  �� o   � ��� 0 _utility  ��  ��  �  f   � ���  ��  �  f   � ��  l  � ��~�~   " # read utilities invoke file    � 8 #   r e a d   u t i l i t i e s   i n v o k e   f i l e 	
	 r   � � b   � � o   � ��}�} 0 _utility   m   � � �  / i n v o k e o      �|�| 0 invoke_file  
 �{ Z   �3�z =   � � n  � � I   � ��y�x�y 0 file_exists   �w o   � ��v�v 0 invoke_file  �w  �x    f   � � m   � ��u
�u boovtrue k   �
  r   � � n  � � !  I   � ��t"�s�t 0 	read_file  " #�r# o   � ��q�q 0 invoke_file  �r  �s  !  f   � � o      �p�p 0 invoke_path   $%$ l  � ��o&'�o  & - '# combine utility path with invoke path   ' �(( N #   c o m b i n e   u t i l i t y   p a t h   w i t h   i n v o k e   p a t h% )*) r   �+,+ b   �-.- b   �/0/ o   � ��n�n 0 _utility  0 m   �11 �22  /. o  �m�m 0 invoke_path  , o      �l�l 0 	full_path  * 3�k3 L  
44 o  	�j�j 0 	full_path  �k  �z   k  355 676 r  (898 n &:;: I  &�i<�h�i 
0 logger  < =>= m  ?? �@@  u t i l i t y> ABA m  CC �DD  1 7 5B EFE m  GG �HH 
 E R R O RF I�gI n  JKJ I   �fL�e�f 0 	formatter  L MNM m  OO �PP R I n t e r n a l   i n v o k e   f i l e   ` { } `   d o e s   n o t   e x i s t .N Q�dQ o  �c�c 0 invoke_file  �d  �e  K  f  �g  �h  ;  f  9 o      �b�b 0 	error_msg  7 RSR R  )1�aTU
�a .ascrerr ****      � ****T o  /0�`�` 0 	error_msg  U �_V�^
�_ 
errnV m  -.�]�] �^  S W�\W l 22�[XY�[  X / )##TODO: need a stable error number schema   Y �ZZ R # # T O D O :   n e e d   a   s t a b l e   e r r o r   n u m b e r   s c h e m a�\  �{  ��  	 [\[ l     �Z�Y�X�Z  �Y  �X  \ ]^] l     �W�V�U�W  �V  �U  ^ _`_ i   ' *aba I      �Tc�S�T 0 icon  c ded o      �R�R 	0 _font  e fgf o      �Q�Q 	0 _name  g hih o      �P�P 
0 _color  i j�Oj o      �N�N 
0 _alter  �O  �S  b k     �kk lml l      �Mno�M  n��  Get path to specified icon, downloading it first if necessary.

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

	   o �pp$     G e t   p a t h   t o   s p e c i f i e d   i c o n ,   d o w n l o a d i n g   i t   f i r s t   i f   n e c e s s a r y . 
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
 	m qrq l     �Lst�L  s : 4# partial support for "optional" args in Applescript   t �uu h #   p a r t i a l   s u p p o r t   f o r   " o p t i o n a l "   a r g s   i n   A p p l e s c r i p tr vwv Z     !xy�K�Jx n    z{z I    �I|�H�I 0 is_empty  | }�G} o    �F�F 
0 _color  �G  �H  {  f     y k   	 ~~ � r   	 ��� m   	 
�� ���  0 0 0 0 0 0� o      �E�E 
0 _color  � ��D� Z    ���C�B� n   ��� I    �A��@�A 0 is_empty  � ��?� o    �>�> 
0 _alter  �?  �@  �  f    � r    ��� m    �=
�= boovtrue� o      �<�< 
0 _alter  �C  �B  �D  �K  �J  w ��� Z   " 2���;�:� n  " (��� I   # (�9��8�9 0 is_empty  � ��7� o   # $�6�6 
0 _alter  �7  �8  �  f   " #� r   + .��� m   + ,�5
�5 boovfals� o      �4�4 
0 _alter  �;  �:  � ��� l  3 3�3���3  �  # path to specific icon   � ��� . #   p a t h   t o   s p e c i f i c   i c o n� ��� r   3 E��� n  3 C��� I   4 C�2��1�2 
0 joiner  � ��� J   4 >�� ��� n  4 9��� I   5 9�0�/�.�0 0 get_icons_dir  �/  �.  �  f   4 5� ��� o   9 :�-�- 	0 _font  � ��� o   : ;�,�, 
0 _color  � ��+� o   ; <�*�* 	0 _name  �+  � ��)� m   > ?�� ���  /�)  �1  �  f   3 4� o      �(�( 	0 _icon  � ��'� Z   F ����&�� =   F N��� n  F L��� I   G L�%��$�% 0 folder_exists  � ��#� o   G H�"�" 	0 _icon  �#  �$  �  f   F G� m   L M�!
�! boovfals� k   Q ��� ��� l  Q Q� ���   � ' !# if icon isn't already installed   � ��� B #   i f   i c o n   i s n ' t   a l r e a d y   i n s t a l l e d� ��� r   Q _��� b   Q ]��� l  Q [���� n  Q [��� I   R [���� 0 dirname  � ��� n  R W��� I   S W���� 0 get_as_bundler  �  �  �  f   R S�  �  �  f   Q R�  �  � m   [ \�� ��� 4 b u n d l e t s / a l f r e d . b u n d l e r . s h� o      �� 0 bash_bundlet  � ��� Z   ` ������ =   ` h��� n  ` f��� I   a f���� 0 file_exists  � ��� o   a b�� 0 bash_bundlet  �  �  �  f   ` a� m   f g�
� boovtrue� k   k ��� ��� r   k p��� n   k n��� 1   l n�
� 
strq� o   k l�� 0 bash_bundlet  � o      �� 0 bash_bundlet_cmd  � ��� r   q ���� n  q ��� I   r ���� 
0 joiner  � ��� J   r z�� ��� o   r s�
�
 0 bash_bundlet_cmd  � ��� m   s t�� ���  i c o n� ��� o   t u�	�	 	0 _font  � ��� o   u v�� 	0 _name  � ��� o   v w�� 
0 _color  � ��� o   w x�� 
0 _alter  �  � ��� 1   z {�
� 
spac�  �  �  f   q r� o      �� 0 cmd  � ��� r   � ���� n  � �� � I   � ��� � 0 prepare_cmd   �� o   � ����� 0 cmd  ��  �      f   � �� o      ���� 0 cmd  �  n  � � I   � ������� 
0 logger   	 m   � �

 �  i c o n	  m   � � �  2 2 2  m   � � �  I N F O �� n  � � I   � ������� 0 	formatter    m   � � � < R u n n i n g   s h e l l   c o m m a n d :   ` { } ` . . . �� o   � ����� 0 cmd  ��  ��    f   � ���  ��    f   � � �� r   � � l  � � ����  I  � ���!��
�� .sysoexecTEXT���     TEXT! o   � ����� 0 cmd  ��  ��  ��   o      ���� 0 	full_path  ��  �  � k   � �"" #$# r   � �%&% n  � �'(' I   � ���)���� 
0 logger  ) *+* m   � �,, �--  i c o n+ ./. m   � �00 �11  2 2 5/ 232 m   � �44 �55 
 E R R O R3 6��6 n  � �787 I   � ���9���� 0 	formatter  9 :;: m   � �<< �== T I n t e r n a l   b a s h   b u n d l e t   ` { } `   d o e s   n o t   e x i s t .; >��> o   � ����� 0 bash_bundlet  ��  ��  8  f   � ���  ��  (  f   � �& o      ���� 0 	error_msg  $ ?��? R   � ���@A
�� .ascrerr ****      � ****@ o   � ����� 0 	error_msg  A ��B��
�� 
errnB m   � ����� ��  ��  �  �&  � k   � �CC DED l  � ���FG��  F $ # if icon is already installed   G �HH < #   i f   i c o n   i s   a l r e a d y   i n s t a l l e dE IJI n  � �KLK I   � ���M���� 
0 logger  M NON m   � �PP �QQ  i c o nO RSR m   � �TT �UU  2 3 0S VWV m   � �XX �YY  I N F OW Z��Z n  � �[\[ I   � ���]���� 0 	formatter  ] ^_^ m   � �`` �aa * I c o n   a t   ` { } `   f o u n d . . ._ b��b o   � ����� 	0 _icon  ��  ��  \  f   � ���  ��  L  f   � �J c��c L   � �dd o   � ����� 	0 _icon  ��  �'  ` efe l     ��������  ��  ��  f ghg l     ��������  ��  ��  h iji l     ��������  ��  ��  j klk l      ��mn��  m   ///
LOGGING HANDLER
///    n �oo 2   / / / 
 L O G G I N G   H A N D L E R 
 / / /  l pqp l     ��������  ��  ��  q rsr i   + .tut I      ��v���� 
0 logger  v wxw o      ���� 0 _handler  x yzy o      ���� 0 line_num  z {|{ o      ���� 
0 _level  | }��} o      ���� 0 _message  ��  ��  u k     �~~ � l      ������  ��� Log information in the standard Alfred-Bundler log file.
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

	do shell script "echo " & theLine & " >> ~/Library/Logs/AppleScript-events.log"
	   � ���   L o g   i n f o r m a t i o n   i n   t h e   s t a n d a r d   A l f r e d - B u n d l e r   l o g   f i l e . 
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
 	 d o   s h e l l   s c r i p t   " e c h o   "   &   t h e L i n e   &   "   > >   ~ / L i b r a r y / L o g s / A p p l e S c r i p t - e v e n t s . l o g " 
 	� ��� l     ������  � E ?# Ensure log file exists, with checking for scope of global var   � ��� ~ #   E n s u r e   l o g   f i l e   e x i s t s ,   w i t h   c h e c k i n g   f o r   s c o p e   o f   g l o b a l   v a r� ��� Q     7���� n   ��� I    ������� 0 
check_file  � ���� n   	��� I    	�������� 0 get_logfile  ��  ��  �  f    ��  ��  �  f    � R      ������
�� .ascrerr ****      � ****��  ��  � k    7�� ��� r    ,��� n   &��� I    &������� 0 	formatter  � ��� l   ������ b    ��� n   ��� I    �������� 0 get_data_dir  ��  ��  �  f    � m    �� ��� ( / l o g s / b u n d l e r - { } . l o g��  ��  � ���� o    "���� "0 bundler_version BUNDLER_VERSION��  ��  �  f    � n     ��� I   ' +�������� 0 get_logfile  ��  ��  �  f   & '� ���� n  - 7��� I   . 7������� 0 
check_file  � ���� n  . 3��� I   / 3�������� 0 get_logfile  ��  ��  �  f   . /��  ��  �  f   - .��  � ��� l  8 8������  � . (# delay to ensure IO action is completed   � ��� P #   d e l a y   t o   e n s u r e   I O   a c t i o n   i s   c o m p l e t e d� ��� I  8 =�����
�� .sysodelanull��� ��� nmbr� m   8 9�� ?���������  � ��� l  > >������  � 4 .# Prepare time string format %Y-%m-%d %H:%M:%S   � ��� \ #   P r e p a r e   t i m e   s t r i n g   f o r m a t   % Y - % m - % d   % H : % M : % S� ��� r   > I��� b   > G��� b   > E��� m   > ?�� ���  [� l  ? D������ n  ? D��� I   @ D�������� 0 date_formatter  ��  ��  �  f   ? @��  ��  � m   E F�� ���  ]� o      ���� 0 log_time  � ��� r   J a��� c   J _��� n   J [��� 7  Q [����
�� 
citm� m   U W���� � m   X Z������� l  J Q������ n   J Q��� 1   O Q��
�� 
tstr� l  J O������ I  J O������
�� .misccurdldt    ��� null��  ��  ��  ��  ��  ��  � m   [ ^��
�� 
TEXT� o      ���� 0 formatterted_time  � ��� r   b m��� b   b k��� b   b g��� m   b e�� ���  [� o   e f���� 0 formatterted_time  � m   g j�� ���  ]� o      ���� 0 
error_time  � ��� l  n n������  �   # Prepare location message   � ��� 4 #   P r e p a r e   l o c a t i o n   m e s s a g e� ��� r   n ��� b   n }��� b   n y��� b   n w��� b   n s��� m   n q�� ���  [ b u n d l e r . s c p t :� o   q r���� 0 _handler  � m   s v�� ���  :� o   w x���� 0 line_num  � m   y |�� ���  ]� o      ���� 0 	_location  � ��� l  � ���� ��  �  # Prepare level message     � . #   P r e p a r e   l e v e l   m e s s a g e�  r   � � b   � � b   � �	 m   � �

 �  [	 o   � ����� 
0 _level   m   � � �  ] o      ���� 
0 _level    l  � �����   / )# Generate full error message for logging    � R #   G e n e r a t e   f u l l   e r r o r   m e s s a g e   f o r   l o g g i n g  r   � � b   � � l  � ����� n  � � I   � ������� 
0 joiner    J   � �  !  o   � ��� 0 log_time  ! "#" o   � ��~�~ 0 	_location  # $%$ o   � ��}�} 
0 _level  % &�|& o   � ��{�{ 0 _message  �|   '�z' 1   � ��y
�y 
spac�z  ��    f   � ���  ��   l  � �(�x�w( I  � ��v)�u
�v .sysontocTEXT       shor) m   � ��t�t 
�u  �x  �w   o      �s�s 0 log_msg   *+* n  � �,-, I   � ��r.�q�r 0 write_to_file  . /0/ o   � ��p�p 0 log_msg  0 121 n  � �343 I   � ��o�n�m�o 0 get_logfile  �n  �m  4  f   � �2 5�l5 m   � ��k
�k boovtrue�l  �q  -  f   � �+ 676 l  � ��j89�j  8 < 6# Generate regular error message for returning to user   9 �:: l #   G e n e r a t e   r e g u l a r   e r r o r   m e s s a g e   f o r   r e t u r n i n g   t o   u s e r7 ;<; r   � �=>= b   � �?@? b   � �ABA b   � �CDC b   � �EFE b   � �GHG b   � �IJI o   � ��i�i 0 
error_time  J 1   � ��h
�h 
spacH o   � ��g�g 0 	_location  F 1   � ��f
�f 
spacD o   � ��e�e 
0 _level  B 1   � ��d
�d 
spac@ o   � ��c�c 0 _message  > o      �b�b 0 	error_msg  < K�aK L   � �LL o   � ��`�` 0 	error_msg  �a  s MNM l     �_�^�]�_  �^  �]  N OPO l      �\QR�\  Q #  ///
SUB-ACTION HANDLERS
///    R �SS :   / / / 
 S U B - A C T I O N   H A N D L E R S 
 / / /  P TUT l     �[�Z�Y�[  �Z  �Y  U VWV i   / 2XYX I      �X�W�V�X 0 date_formatter  �W  �V  Y k     �ZZ [\[ l      �U]^�U  ] � � Format current date and time into %Y-%m-%d %H:%M:%S string format.
	
	:returns: Formatted date-time stamp
	:rtype: ``string``
		
	   ^ �__   F o r m a t   c u r r e n t   d a t e   a n d   t i m e   i n t o   % Y - % m - % d   % H : % M : % S   s t r i n g   f o r m a t . 
 	 
 	 : r e t u r n s :   F o r m a t t e d   d a t e - t i m e   s t a m p 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	\ `a` r     !bcb I     �T�S�R
�T .misccurdldt    ��� null�S  �R  c K    
dd �Qef
�Q 
yeare o    �P�P 0 y  f �Ogh
�O 
mnthg o    �N�N 0 m  h �Mi�L
�M 
day i o    �K�K 0 d  �L  a jkj r   " /lml c   " -non l  " +p�J�Ip [   " +qrq [   " )sts ]   " %uvu o   " #�H�H 0 y  v m   # $�G�G't ]   % (wxw o   % &�F�F 0 m  x m   & '�E�E dr o   ) *�D�D 0 d  �J  �I  o m   + ,�C
�C 
TEXTm o      �B�B 0 date_num  k yzy r   0 _{|{ l  0 ]}�A�@} b   0 ]~~ b   0 M��� b   0 I��� b   0 =��� l  0 ;��?�>� n   0 ;��� 7  1 ;�=��
�= 
ctxt� m   5 7�<�< � m   8 :�;�; � o   0 1�:�: 0 date_num  �?  �>  � m   ; <�� ���  -� l  = H��9�8� n   = H��� 7  > H�7��
�7 
ctxt� m   B D�6�6 � m   E G�5�5 � o   = >�4�4 0 date_num  �9  �8  � m   I L�� ���  - l  M \��3�2� n   M \��� 7  N \�1��
�1 
ctxt� m   R V�0�0 � m   W [�/�/ � o   M N�.�. 0 date_num  �3  �2  �A  �@  | o      �-�- 0 formatterted_date  z ��� r   ` {��� c   ` y��� n   ` w��� 7  i w�,��
�, 
citm� m   o q�+�+ � m   r v�*�*��� l  ` i��)�(� n   ` i��� 1   e i�'
�' 
tstr� l  ` e��&�%� I  ` e�$�#�"
�$ .misccurdldt    ��� null�#  �"  �&  �%  �)  �(  � m   w x�!
�! 
TEXT� o      � �  0 formatterted_time  � ��� L   | ��� b   | ���� b   | ���� o   | }�� 0 formatterted_date  � 1   } ��
� 
spac� o   � ��� 0 formatterted_time  �  W ��� l     ����  �  �  � ��� i   3 6��� I      ���� 0 prepare_cmd  � ��� o      �� 0 cmd  �  �  � k     �� ��� l      ����  � � � Ensure shell `_cmd` is working from the proper directory.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:returns: ``string``

	   � ����   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r   d i r e c t o r y . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r e t u r n s :   ` ` s t r i n g ` ` 
 
 	� ��� r     	��� n     ��� 1    �
� 
strq� l    ���� n    ��� I    ���� 0 pwd  �  �  �  f     �  �  � o      �� 0 pwd  � ��� L   
 �� b   
 ��� b   
 ��� b   
 ��� m   
 �� ���  c d  � o    �� 0 pwd  � m    �� ���  ;   b a s h  � o    �
�
 0 cmd  �  � ��� l     �	���	  �  �  � ��� l     ����  �  �  � ��� l      ����  � #  ///
IO HELPER FUNCTIONS
///    � ��� :   / / / 
 I O   H E L P E R   F U N C T I O N S 
 / / /  � ��� l     ��� �  �  �   � ��� i   7 :��� I      ������� 0 write_to_file  � ��� o      ���� 0 	this_data  � ��� o      ���� 0 target_file  � ���� o      ���� 0 append_data  ��  ��  � k     Y�� ��� l      ������  ��� Write or append `this_data` to `target_file`.
	
	:param this_data: The text to be written to the file
	:type this_data: ``string``
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:param append_data: Overwrite or append text to file?
	:type append_data: ``Boolean``
	:returns: Was the write successful?
	:rtype: ``Boolean``
		
	   � ���   W r i t e   o r   a p p e n d   ` t h i s _ d a t a `   t o   ` t a r g e t _ f i l e ` . 
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
 	� ���� Q     Y���� k    :�� ��� r    ��� c    ��� l   ������ o    ���� 0 target_file  ��  ��  � m    ��
�� 
TEXT� l     ������ o      ���� 0 target_file  ��  ��  � ��� r   	 ��� I  	 ����
�� .rdwropenshor       file� 4   	 ���
�� 
psxf� o    ���� 0 target_file  � �����
�� 
perm� m    ��
�� boovtrue��  � l      ����  o      ���� 0 open_target_file  ��  ��  �  Z   '���� =    o    ���� 0 append_data   m    ��
�� boovfals I   #��
�� .rdwrseofnull���     **** l   	����	 o    ���� 0 open_target_file  ��  ��   ��
��
�� 
set2
 m    ����  ��  ��  ��    I  ( 1��
�� .rdwrwritnull���     **** o   ( )���� 0 	this_data   ��
�� 
refn l  * +���� o   * +���� 0 open_target_file  ��  ��   ����
�� 
wrat m   , -��
�� rdwreof ��    I  2 7����
�� .rdwrclosnull���     **** l  2 3���� o   2 3���� 0 open_target_file  ��  ��  ��   �� L   8 : m   8 9��
�� boovtrue��  � R      ������
�� .ascrerr ****      � ****��  ��  � k   B Y  Q   B V�� I  E M����
�� .rdwrclosnull���     **** 4   E I��
�� 
file o   G H���� 0 target_file  ��   R      ������
�� .ascrerr ****      � ****��  ��  ��    ��  L   W Y!! m   W X��
�� boovfals��  ��  � "#" l     ��������  ��  ��  # $%$ i   ; >&'& I      ��(���� 0 	read_file  ( )��) o      ���� 0 target_file  ��  ��  ' k     ** +,+ l      ��-.��  - � � Read data from `target_file`.
	
	:param target_file: Full path to the file to be written to
	:type target_file: ``string`` (POSIX path)
	:returns: Data contained in `target_file`
	:rtype: ``string``
		
	   . �//�   R e a d   d a t a   f r o m   ` t a r g e t _ f i l e ` . 
 	 
 	 : p a r a m   t a r g e t _ f i l e :   F u l l   p a t h   t o   t h e   f i l e   t o   b e   w r i t t e n   t o 
 	 : t y p e   t a r g e t _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   D a t a   c o n t a i n e d   i n   ` t a r g e t _ f i l e ` 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	, 010 I    ��2��
�� .rdwropenshor       file2 4     ��3
�� 
psxf3 o    ���� 0 target_file  ��  1 454 r   	 676 l  	 8����8 I  	 ��9��
�� .rdwrread****        ****9 o   	 
���� 0 target_file  ��  ��  ��  7 o      ���� 0 	_contents  5 :;: I   ��<��
�� .rdwrclosnull���     ****< o    ���� 0 target_file  ��  ; =��= L    >> o    ���� 0 	_contents  ��  % ?@? l     ��������  ��  ��  @ ABA i   ? BCDC I      �������� 0 pwd  ��  ��  D k     8EE FGF l      ��HI��  H � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   I �JJJ   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	G KLK r     MNM J     OO PQP n    RSR 1    ��
�� 
txdlS 1     ��
�� 
ascrQ T��T m    UU �VV  /��  N J      WW XYX o      ���� 0 astid ASTIDY Z��Z n     [\[ 1    ��
�� 
txdl\ 1    ��
�� 
ascr��  L ]^] r    /_`_ b    -aba l   +c����c c    +ded n    )fgf 7   )��hi
�� 
citmh m   # %���� i m   & (������g l   j����j n    klk 1    ��
�� 
psxpl l   m����m I   ��n��
�� .earsffdralis        afdrn  f    ��  ��  ��  ��  ��  e m   ) *��
�� 
TEXT��  ��  b m   + ,oo �pp  /` o      ���� 	0 _path  ^ qrq r   0 5sts o   0 1���� 0 astid ASTIDt n     uvu 1   2 4��
�� 
txdlv 1   1 2��
�� 
ascrr w��w L   6 8xx o   6 7���� 	0 _path  ��  B yzy l     ��������  ��  ��  z {|{ i   C F}~} I      ������ 0 dirname   ���� o      ���� 	0 _file  ��  ��  ~ k     2�� ��� l      ������  � � � Get name of directory containing `_file`.
	
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
 	� ��� r     ��� J     �� ��� n    ��� 1    �
� 
txdl� 1     �~
�~ 
ascr� ��}� m    �� ���  /�}  � J      �� ��� o      �|�| 0 astid ASTID� ��{� n     ��� 1    �z
�z 
txdl� 1    �y
�y 
ascr�{  � ��� r    )��� b    '��� l   %��x�w� c    %��� n    #��� 7   #�v��
�v 
citm� m    �u�u � m     "�t�t��� o    �s�s 	0 _file  � m   # $�r
�r 
TEXT�x  �w  � m   % &�� ���  /� o      �q�q 	0 _path  � ��� r   * /��� o   * +�p�p 0 astid ASTID� n     ��� 1   , .�o
�o 
txdl� 1   + ,�n
�n 
ascr� ��m� L   0 2�� o   0 1�l�l 	0 _path  �m  | ��� l     �k�j�i�k  �j  �i  � ��� i   G J��� I      �h��g�h 0 	check_dir  � ��f� o      �e�e 0 _folder  �f  �g  � k     �� ��� l      �d���d  � � � Check if `_folder` exists, and if not create it and any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	   � ���"   C h e c k   i f   ` _ f o l d e r `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t   a n d   a n y   s u b - d i r e c t o r i e s . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ f o l d e r ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ��� Z     ���c�b� H     �� n    ��� I    �a��`�a 0 folder_exists  � ��_� o    �^�^ 0 _folder  �_  �`  �  f     � I  
 �]��\
�] .sysoexecTEXT���     TEXT� b   
 ��� m   
 �� ���  m k d i r   - p  � l   ��[�Z� n    ��� 1    �Y
�Y 
strq� o    �X�X 0 _folder  �[  �Z  �\  �c  �b  � ��W� L    �� o    �V�V 0 _folder  �W  � ��� l     �U�T�S�U  �T  �S  � ��� i   K N��� I      �R��Q�R 0 
check_file  � ��P� o      �O�O 	0 _path  �P  �Q  � k     -�� ��� l      �N���N  � � � Check if `_path` exists, and if not create it and its directory tree.

	:returns: POSIX path to `_path`
	:rtype: ``string`` (POSIX path)

	   � ���   C h e c k   i f   ` _ p a t h `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t   a n d   i t s   d i r e c t o r y   t r e e . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ p a t h ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ��M� Z     -���L�K� H     �� n    ��� I    �J��I�J 0 file_exists  � ��H� o    �G�G 	0 _path  �H  �I  �  f     � k   
 )�� ��� r   
 ��� I   
 �F��E�F 0 dirname  � ��D� o    �C�C 	0 _path  �D  �E  � o      �B�B 0 _dir  � ��� n   ��� I    �A��@�A 0 	check_dir  � ��?� o    �>�> 0 _dir  �?  �@  �  f    � ��� I   �=��<
�= .sysodelanull��� ��� nmbr� m    �� ?��������<  � ��;� I    )�:��9
�: .sysoexecTEXT���     TEXT� b     %��� m     !�� ���  t o u c h  � l  ! $��8�7� n   ! $� � 1   " $�6
�6 
strq  o   ! "�5�5 	0 _path  �8  �7  �9  �;  �L  �K  �M  �  l     �4�3�2�4  �3  �2    i   O R I      �1�0�1 0 folder_exists   �/ o      �.�. 0 _folder  �/  �0   k     		 

 l      �-�-   � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	  Z     �,�+ n     I    �*�)�* 0 path_exists   �( o    �'�' 0 _folder  �(  �)    f      O   	  L     l   �&�% =    n     m    �$
�$ 
pcls l   �#�" 4    �! 
�! 
ditm  o    � �  0 _folder  �#  �"   m    �
� 
cfol�&  �%   m   	 
!!�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �,  �+   "�" L    ## m    �
� boovfals�   $%$ l     ����  �  �  % &'& i   S V()( I      �*�� 0 file_exists  * +�+ o      �� 	0 _file  �  �  ) k     ,, -.- l      �/0�  / � � Return ``true`` if `_file` exists, else ``false``

	:param _file: Full path to file
	:type _file: ``string`` (POSIX path)
	:returns: ``Boolean``

	   0 �11(   R e t u r n   ` ` t r u e ` `   i f   ` _ f i l e `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f i l e :   F u l l   p a t h   t o   f i l e 
 	 : t y p e   _ f i l e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	. 232 Z     45��4 n    676 I    �8�� 0 path_exists  8 9�9 o    �� 	0 _file  �  �  7  f     5 O   	 :;: L    << l   =��= =   >?> n    @A@ m    �
� 
pclsA l   B��
B 4    �	C
�	 
ditmC o    �� 	0 _file  �  �
  ? m    �
� 
file�  �  ; m   	 
DD�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �  �  3 E�E L    FF m    �
� boovfals�  ' GHG l     ����  �  �  H IJI i   W ZKLK I      �M� � 0 path_exists  M N��N o      ���� 	0 _path  ��  �   L k     YOO PQP l      ��RS��  R � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	   S �TTD   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	Q UVU Z    WX����W G     YZY =    [\[ o     ���� 	0 _path  \ m    ��
�� 
msngZ n   ]^] I    ��_���� 0 is_empty  _ `��` o    ���� 	0 _path  ��  ��  ^  f    X L    aa m    ��
�� boovfals��  ��  V bcb l   ��������  ��  ��  c d��d Q    Yefge k    Ohh iji Z   )kl����k =    mnm n    opo m    ��
�� 
pclsp o    ���� 	0 _path  n m    ��
�� 
alisl L   # %qq m   # $��
�� boovtrue��  ��  j r��r Z   * Ostuvs E   * -wxw o   * +���� 	0 _path  x m   + ,yy �zz  :t k   0 8{{ |}| 4   0 5��~
�� 
alis~ o   2 3���� 	0 _path  } �� L   6 8�� m   6 7��
�� boovtrue��  u ��� E   ; >��� o   ; <���� 	0 _path  � m   < =�� ���  /� ���� k   A J�� ��� c   A G��� 4   A E���
�� 
psxf� o   C D���� 	0 _path  � m   E F��
�� 
alis� ���� L   H J�� m   H I��
�� boovtrue��  ��  v L   M O�� m   M N��
�� boovfals��  f R      �����
�� .ascrerr ****      � ****� o      ���� 0 msg  ��  g L   W Y�� m   W X��
�� boovfals��  J ��� l     ��������  ��  ��  � ��� l      ������  � %  ///
TEXT HELPER FUNCTIONS
///    � ��� >   / / / 
 T E X T   H E L P E R   F U N C T I O N S 
 / / /  � ��� l     ��������  ��  ��  � ��� i   [ ^��� I      ������� 	0 split  � ��� o      ���� 0 str  � ���� o      ���� 	0 delim  ��  ��  � k     3�� ��� l      ������  � � � Split a string into a list

	:param str: A text string
	:type str: ``string``
	:param delim: Where to split `str` into pieces
	:type delim: ``string``
	:returns: the split list
	:rtype: ``list``

	   � ����   S p l i t   a   s t r i n g   i n t o   a   l i s t 
 
 	 : p a r a m   s t r :   A   t e x t   s t r i n g 
 	 : t y p e   s t r :   ` ` s t r i n g ` ` 
 	 : p a r a m   d e l i m :   W h e r e   t o   s p l i t   ` s t r `   i n t o   p i e c e s 
 	 : t y p e   d e l i m :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t h e   s p l i t   l i s t 
 	 : r t y p e :   ` ` l i s t ` ` 
 
 	� ��� q      �� ����� 	0 delim  � ����� 0 str  � ������ 0 astid ASTID��  � ��� r     ��� n    ��� 1    ��
�� 
txdl� 1     ��
�� 
ascr� o      ���� 0 astid ASTID� ���� Q    3���� k   	 �� ��� r   	 ��� o   	 
���� 	0 delim  � n     ��� 1    ��
�� 
txdl� 1   
 ��
�� 
ascr� ��� r    ��� n    ��� 2   ��
�� 
citm� o    ���� 0 str  � o      ���� 0 str  � ��� r    ��� o    ���� 0 astid ASTID� n     ��� 1    ��
�� 
txdl� 1    ��
�� 
ascr� ���� l   ���� L    �� o    ���� 0 str  �  > list   � ���  >   l i s t��  � R      ����
�� .ascrerr ****      � ****� o      ���� 0 msg  � �����
�� 
errn� o      ���� 0 num  ��  � k   % 3�� ��� r   % *��� o   % &���� 0 astid ASTID� n     ��� 1   ' )��
�� 
txdl� 1   & '��
�� 
ascr� ���� R   + 3����
�� .ascrerr ****      � ****� b   / 2��� m   / 0�� ���  C a n ' t   e x p l o d e :  � o   0 1���� 0 msg  � �����
�� 
errn� o   - .���� 0 num  ��  ��  ��  � ��� l     ��������  ��  ��  � ��� i   _ b��� I      ������� 0 	formatter  � ��� o      ���� 0 str  � ���� o      ���� 0 arg  ��  ��  � k     E�� ��� l      ������  � � � Replace `{}` in `str` with `arg`

	:param str: A text string with one instance of `{}`
	:type str: ``string``
	:param arg: The text to replace `{}`
	:type arg: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   � ����   R e p l a c e   ` { } `   i n   ` s t r `   w i t h   ` a r g ` 
 
 	 : p a r a m   s t r :   A   t e x t   s t r i n g   w i t h   o n e   i n s t a n c e   o f   ` { } ` 
 	 : t y p e   s t r :   ` ` s t r i n g ` ` 
 	 : p a r a m   a r g :   T h e   t e x t   t o   r e p l a c e   ` { } ` 
 	 : t y p e   a r g :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	� ��� q      �� ����� 0 astid ASTID� ����� 0 str  � ����� 0 arg  � ������ 0 lst  ��  � ��� r     ��� n    ��� 1    ��
�� 
txdl� 1     ��
�� 
ascr� o      ���� 0 astid ASTID�  ��  Q    E k   	 /  P   	 &�� k    %		 

 r     m     �  { } n      1    ��
�� 
txdl 1    ��
�� 
ascr  r     n     2    ��
�� 
citm o    ���� 0 str   o      ���� 0 lst    r     o    ���� 0 arg   n      1    ��
�� 
txdl 1    ��
�� 
ascr �� r     %  c     #!"! o     !���� 0 lst  " m   ! "��
�� 
TEXT  o      ���� 0 str  ��   ����
�� conscase��  ��   #$# r   ' ,%&% o   ' (���� 0 astid ASTID& n     '(' 1   ) +��
�� 
txdl( 1   ( )��
�� 
ascr$ )��) L   - /** o   - .���� 0 str  ��   R      ��+,
�� .ascrerr ****      � ****+ o      ���� 0 msg  , ��-��
�� 
errn- o      �� 0 num  ��   k   7 E.. /0/ r   7 <121 o   7 8�~�~ 0 astid ASTID2 n     343 1   9 ;�}
�} 
txdl4 1   8 9�|
�| 
ascr0 5�{5 R   = E�z67
�z .ascrerr ****      � ****6 b   A D898 m   A B:: �;; * C a n ' t   r e p l a c e S t r i n g :  9 o   B C�y�y 0 msg  7 �x<�w
�x 
errn< o   ? @�v�v 0 num  �w  �{  ��  � =>= l     �u�t�s�u  �t  �s  > ?@? i   c fABA I      �rC�q�r 0 trim  C D�pD o      �o�o 0 _str  �p  �q  B k     �EE FGF l      �nHI�n  H � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   I �JJ4   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	G KLK Z     MN�m�lM G     OPO G     QRQ >    STS n     UVU m    �k
�k 
pclsV o     �j�j 0 _str  T m    �i
�i 
ctxtR >   WXW n    YZY m   	 �h
�h 
pclsZ o    	�g�g 0 _str  X m    �f
�f 
TEXTP =   [\[ o    �e�e 0 _str  \ m    �d
�d 
msngN L    ]] o    �c�c 0 _str  �m  �l  L ^_^ Z  ! -`a�b�a` =  ! $bcb o   ! "�`�` 0 _str  c m   " #dd �ee  a L   ' )ff o   ' (�_�_ 0 _str  �b  �a  _ ghg V   . Wiji Q   6 Rklmk r   9 Hnon c   9 Fpqp n   9 Drsr 7  : D�^tu
�^ 
cobjt m   > @�]�] u m   A C�\�\��s o   9 :�[�[ 0 _str  q m   D E�Z
�Z 
ctxto o      �Y�Y 0 _str  l R      �Xv�W
�X .ascrerr ****      � ****v o      �V�V 0 msg  �W  m L   P Rww m   P Qxx �yy  j C  2 5z{z o   2 3�U�U 0 _str  { m   3 4|| �}}   h ~~ V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n�T��
�T 
cobj� m   h j�S�S � m   k m�R�R��� o   c d�Q�Q 0 _str  � m   n o�P
�P 
ctxt� o      �O�O 0 _str  � R      �N�M�L
�N .ascrerr ****      � ****�M  �L  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�K�K 0 _str  � m   ] ^�� ���    ��J� L   � ��� o   � ��I�I 0 _str  �J  @ ��� l     �H�G�F�H  �G  �F  � ��� i   g j��� I      �E��D�E 
0 joiner  � ��� o      �C�C 
0 pieces  � ��B� o      �A�A 	0 delim  �B  �D  � k     3�� ��� l      �@���@  � � Join list of `pieces` into a string delimted by `delim`.

	:param pieces: A list of objects
	:type pieces: ``list``
	:param delim: The text item by which to join the list items
	:type delim: ``string``
	:returns: trimmed string
	:rtype: ``string``

	   � ����   J o i n   l i s t   o f   ` p i e c e s `   i n t o   a   s t r i n g   d e l i m t e d   b y   ` d e l i m ` . 
 
 	 : p a r a m   p i e c e s :   A   l i s t   o f   o b j e c t s 
 	 : t y p e   p i e c e s :   ` ` l i s t ` ` 
 	 : p a r a m   d e l i m :   T h e   t e x t   i t e m   b y   w h i c h   t o   j o i n   t h e   l i s t   i t e m s 
 	 : t y p e   d e l i m :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 
 	� ��� q      �� �?��? 	0 delim  � �>��> 
0 pieces  � �=�<�= 0 astid ASTID�<  � ��� r     ��� n    ��� 1    �;
�; 
txdl� 1     �:
�: 
ascr� o      �9�9 0 astid ASTID� ��8� Q    3���� k   	 �� ��� r   	 ��� o   	 
�7�7 	0 delim  � n     ��� 1    �6
�6 
txdl� 1   
 �5
�5 
ascr� ��� r    ��� b    ��� m    �� ���  � o    �4�4 
0 pieces  � o      �3�3 
0 pieces  � ��� r    ��� o    �2�2 0 astid ASTID� n     ��� 1    �1
�1 
txdl� 1    �0
�0 
ascr� ��/� l   ���� L    �� o    �.�. 
0 pieces  �  > text   � ���  >   t e x t�/  � R      �-��
�- .ascrerr ****      � ****� o      �,�, 0 emsg  � �+��*
�+ 
errn� o      �)�) 0 enum eNum�*  � k   % 3�� ��� r   % *��� o   % &�(�( 0 astid ASTID� n     ��� 1   ' )�'
�' 
txdl� 1   & '�&
�& 
ascr� ��%� R   + 3�$��
�$ .ascrerr ****      � ****� b   / 2��� m   / 0�� ���  C a n ' t   i m p l o d e :  � o   0 1�#�# 0 emsg  � �"��!
�" 
errn� o   - .� �  0 enum eNum�!  �%  �8  � ��� l     ����  �  �  � ��� l      ����  � , & ///
LOWER LEVEL HELPER FUNCTIONS
///    � ��� L   / / / 
 L O W E R   L E V E L   H E L P E R   F U N C T I O N S 
 / / /  � ��� l     ����  �  �  � ��� i   k n��� I      ���� 0 is_empty  � ��� o      �� 0 _obj  �  �  � k     (�� ��� l      ����  � � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:rtype: ``Boolean``
		
	   � ���   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r t y p e :   ` ` B o o l e a n ` ` 
 	 	 
 	� ��� Z    ����� E     ��� J     �� ��� m     �
� boovtrue� ��� m    �
� boovfals�  � o    �� 0 _obj  � L   	 	 	  m   	 
�
� boovfals�  �  � 			 Z   		��
	 =   			 o    �	�	 0 _obj  	 m    �
� 
msng	 L    		 m    �
� boovtrue�  �
  	 	�	 L    (				 =   '	
		
 n    %			 1   # %�
� 
leng	 l   #	��	 n   #			 I    #�	�� 0 trim  	 	� 	 o    ���� 0 _obj  �   �  	  f    �  �  	 m   % &����  �  �       ��	 													 	!	"	#	$	%	&	'	(	)	*	+	,	-	.��  	 ���������������������������������������������������������� "0 bundler_version BUNDLER_VERSION�� 0 get_bundler_dir  �� 0 get_data_dir  �� 0 get_as_bundler  �� 0 
get_as_dir  �� 0 get_utils_dir  �� 0 get_icons_dir  �� 0 get_logfile  �� 0 library  �� 0 utility  �� 0 icon  �� 
0 logger  �� 0 date_formatter  �� 0 prepare_cmd  �� 0 write_to_file  �� 0 	read_file  �� 0 pwd  �� 0 dirname  �� 0 	check_dir  �� 0 
check_file  �� 0 folder_exists  �� 0 file_exists  �� 0 path_exists  �� 	0 split  �� 0 	formatter  �� 0 trim  �� 
0 joiner  �� 0 is_empty  	 ��  ����	/	0���� 0 get_bundler_dir  ��  ��  	/  	0 ���������� -
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %	 �� 9����	1	2���� 0 get_data_dir  ��  ��  	1  	2 �� @�� 0 get_bundler_dir  �� 	)j+  �%	 �� L����	3	4���� 0 get_as_bundler  ��  ��  	3  	4 �� S�� 0 get_bundler_dir  �� 	)j+  �%	 �� _����	5	6���� 0 
get_as_dir  ��  ��  	5  	6 �� f�� 0 get_data_dir  �� 	)j+  �%	 �� r����	7	8���� 0 get_utils_dir  ��  ��  	7  	8 �� y�� 0 get_data_dir  �� 	)j+  �%	 �� �����	9	:���� 0 get_icons_dir  ��  ��  	9  	: �� ��� 0 get_data_dir  �� 	)j+  �%	 �� �����	;	<���� 0 get_logfile  ��  ��  	; ������ 0 unformatted_path  �� "0 bundler_logfile BUNDLER_LOGFILE	< �� ����� 0 get_data_dir  �� 0 	formatter  �� )j+  �%E�O)�b   l+ E�	 �� �����	=	>���� 0 library  �� ��	?�� 	?  �������� 	0 _name  �� 0 _version  �� 0 
_json_path  ��  	= �������������������������� 	0 _name  �� 0 _version  �� 0 
_json_path  �� 	0 _json  �� 0 _library  �� 0 bash_bundlet  �� 0 bash_bundlet_cmd  �� 0 cmd  �� 0 	full_path  �� 0 	error_msg  �� 0 invoke_file  �� 0 invoke_path  	> )�� � ��� �������������=������TX\d����������z~������������������ 0 is_empty  �� 0 
get_as_dir  �� 
0 joiner  �� 0 folder_exists  �� 0 get_as_bundler  �� 0 dirname  �� 0 file_exists  
�� 
strq�� 
�� 
spac�� 0 prepare_cmd  �� 0 	formatter  �� �� 
0 logger  
�� .sysoexecTEXT���     TEXT
�� .sysoloadscpt        file
�� 
errn�� 0 	read_file  ��8)�k+   �E�Y hO)�k+   �E�Y hO))j+ ��mv�l+ E�O)�k+ f  �))j+ k+ �%E�O)�k+ 
e  L��,E�O)�젡��v�l+ E�O)�k+ E�O)a a a )a �l+ a + O�j E�O�j Y &)a a a )a �l+ a + E�O)a kl�Y o)a a a  )a !�l+ a + O�a "%E�O)�k+ 
e  )�k+ #E�O�a $%�%E�O�j Y &)a %a &a ')a (�l+ a + E�O)a kl�	 ������	@	A���� 0 utility  �� ��	B�� 	B  �������� 	0 _name  �� 0 _version  �� 0 
_json_path  ��  	@ ��������������������~�}�� 	0 _name  �� 0 _version  �� 0 
_json_path  �� 	0 _json  �� 0 _utility  �� 0 bash_bundlet  �� 0 bash_bundlet_cmd  �� 0 cmd  �� 0 	full_path  � 0 	error_msg  �~ 0 invoke_file  �} 0 invoke_path  	A (�|'3�{L�z�y�x�wk�v�u��t�s�r�����q�p�o�n�����m����l1?CGO�| 0 is_empty  �{ 0 get_utils_dir  �z 
0 joiner  �y 0 folder_exists  �x 0 get_as_bundler  �w 0 dirname  �v 0 file_exists  
�u 
strq�t 
�s 
spac�r 0 prepare_cmd  �q 0 	formatter  �p �o 
0 logger  
�n .sysoexecTEXT���     TEXT
�m 
errn�l 0 	read_file  ��4)�k+   �E�Y hO)�k+   �E�Y hO))j+ ��mv�l+ E�O)�k+ f  �))j+ k+ �%E�O)�k+ 
e  H��,E�O)�젡��v�l+ E�O)�k+ E�O)a a a )a �l+ a + O�j E�O�Y ()a a a )a �l+ a + E�O)a kl�OPY m)a a a )a  �l+ a + O�a !%E�O)�k+ 
e  )�k+ "E�O�a #%�%E�O�Y ()a $a %a &)a '�l+ a + E�O)a kl�OP	 �kb�j�i	C	D�h�k 0 icon  �j �g	E�g 	E  �f�e�d�c�f 	0 _font  �e 	0 _name  �d 
0 _color  �c 
0 _alter  �i  	C 
�b�a�`�_�^�]�\�[�Z�Y�b 	0 _font  �a 	0 _name  �` 
0 _color  �_ 
0 _alter  �^ 	0 _icon  �] 0 bash_bundlet  �\ 0 bash_bundlet_cmd  �[ 0 cmd  �Z 0 	full_path  �Y 0 	error_msg  	D  �X��W�V��U�T�S�R��Q�P��O�N�M
�L�K�J,04<�IPTX`�X 0 is_empty  �W 0 get_icons_dir  �V �U 
0 joiner  �T 0 folder_exists  �S 0 get_as_bundler  �R 0 dirname  �Q 0 file_exists  
�P 
strq�O 
�N 
spac�M 0 prepare_cmd  �L 0 	formatter  �K 
0 logger  
�J .sysoexecTEXT���     TEXT
�I 
errn�h �)�k+   �E�O)�k+   eE�Y hY hO)�k+   fE�Y hO))j+ ����v�l+ E�O)�k+ f  �))j+ k+ �%E�O)�k+ 
e  D��,E�O)�젡���v�l+ E�O)�k+ E�O)a a a )a �l+ �+ O�j E�Y $)a a a )a �l+ �+ E�O)a kl�Y )a a a )a �l+ �+ O�	 �Hu�G�F	F	G�E�H 
0 logger  �G �D	H�D 	H  �C�B�A�@�C 0 _handler  �B 0 line_num  �A 
0 _level  �@ 0 _message  �F  	F 
�?�>�=�<�;�:�9�8�7�6�? 0 _handler  �> 0 line_num  �= 
0 _level  �< 0 _message  �; 0 log_time  �: 0 formatterted_time  �9 0 
error_time  �8 0 	_location  �7 0 log_msg  �6 0 	error_msg  	G �5�4�3�2�1��0��/��.��-�,�+�*�)�����
�(�'�&�%�$�#�5 0 get_logfile  �4 0 
check_file  �3  �2  �1 0 get_data_dir  �0 0 	formatter  
�/ .sysodelanull��� ��� nmbr�. 0 date_formatter  
�- .misccurdldt    ��� null
�, 
tstr
�+ 
citm�*��
�) 
TEXT�( 
�' 
spac�& 
0 joiner  �% 

�$ .sysontocTEXT       shor�# 0 write_to_file  �E � ))j+  k+ W )X  ))j+ �%b   l+ )j+  FO))j+  k+ O�j O�)j+ 
%�%E�O*j �,[�\[Zk\Z�2a &E�Oa �%a %E�Oa �%a %�%a %E�Oa �%a %E�O)����a v_ l+ a j %E�O)�)j+  em+ O�_ %�%_ %�%_ %�%E�O�	 �"Y�!� 	I	J��" 0 date_formatter  �!  �   	I ������� 0 y  � 0 m  � 0 d  � 0 date_num  � 0 formatterted_date  � 0 formatterted_time  	J ����������������
��	�����
� 
Krtn
� 
year� 0 y  
� 
mnth� 0 m  
� 
day � 0 d  � 
� .misccurdldt    ��� null�'� d
� 
TEXT
� 
ctxt� �
 �	 � 
� 
tstr
� 
citm���
� 
spac� �*��������l E[�,E�Z[�,E�Z[�,E�ZO�� �� ��&E�O�[�\[Zk\Z�2�%�[�\[Z�\Z�2%a %�[�\[Za \Za 2%E�O*j a ,[a \[Zk\Za 2�&E�O�_ %�%	  ����	K	L� � 0 prepare_cmd  � ��	M�� 	M  ���� 0 cmd  �  	K ������ 0 cmd  �� 0 pwd  	L �������� 0 pwd  
�� 
strq�  )j+  �,E�O�%�%�%	! �������	N	O���� 0 write_to_file  �� ��	P�� 	P  �������� 0 	this_data  �� 0 target_file  �� 0 append_data  ��  	N ���������� 0 	this_data  �� 0 target_file  �� 0 append_data  �� 0 open_target_file  	O ������������������������������
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
O�j OeW X   *�/j W X  hOf	" ��'����	Q	R���� 0 	read_file  �� ��	S�� 	S  ���� 0 target_file  ��  	Q ������ 0 target_file  �� 0 	_contents  	R ��������
�� 
psxf
�� .rdwropenshor       file
�� .rdwrread****        ****
�� .rdwrclosnull���     ****�� *�/j O�j E�O�j O�	# ��D����	T	U���� 0 pwd  ��  ��  	T ������ 0 astid ASTID�� 	0 _path  	U 
����U������������o
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�	$ ��~����	V	W���� 0 dirname  �� ��	X�� 	X  ���� 	0 _file  ��  	V �������� 	0 _file  �� 0 astid ASTID�� 	0 _path  	W ��������������
�� 
ascr
�� 
txdl
�� 
cobj
�� 
citm����
�� 
TEXT�� 3��,�lvE[�k/E�Z[�l/��,FZO�[�\[Zk\Z�2�&�%E�O���,FO�	% �������	Y	Z���� 0 	check_dir  �� ��	[�� 	[  ���� 0 _folder  ��  	Y ���� 0 _folder  	Z ��������� 0 folder_exists  
�� 
strq
�� .sysoexecTEXT���     TEXT�� )�k+   ��,%j Y hO�	& �������	\	]���� 0 
check_file  �� ��	^�� 	^  ���� 	0 _path  ��  	\ ������ 	0 _path  �� 0 _dir  	] ���������������� 0 file_exists  �� 0 dirname  �� 0 	check_dir  
�� .sysodelanull��� ��� nmbr
�� 
strq
�� .sysoexecTEXT���     TEXT�� .)�k+   $*�k+ E�O)�k+ O�j O��,%j Y h	' ������	_	`���� 0 folder_exists  �� ��	a�� 	a  ���� 0 _folder  ��  	_ ���� 0 _folder  	` ��!�������� 0 path_exists  
�� 
ditm
�� 
pcls
�� 
cfol�� )�k+   � *�/�,� UY hOf	( ��)����	b	c���� 0 file_exists  �� ��	d�� 	d  ���� 	0 _file  ��  	b ���� 	0 _file  	c ��D�������� 0 path_exists  
�� 
ditm
�� 
pcls
�� 
file�� )�k+   � *�/�,� UY hOf	) ��L����	e	f���� 0 path_exists  �� ��	g�� 	g  ���� 	0 _path  ��  	e ������ 	0 _path  �� 0 msg  	f 
��~�}�|�{y��z�y�x
� 
msng�~ 0 is_empty  
�} 
bool
�| 
pcls
�{ 
alis
�z 
psxf�y 0 msg  �x  �� Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f	* �w��v�u	h	i�t�w 	0 split  �v �s	j�s 	j  �r�q�r 0 str  �q 	0 delim  �u  	h �p�o�n�m�l�p 0 str  �o 	0 delim  �n 0 astid ASTID�m 0 msg  �l 0 num  	i �k�j�i�h	k�g�
�k 
ascr
�j 
txdl
�i 
citm�h 0 msg  	k �f�e�d
�f 
errn�e 0 num  �d  
�g 
errn�t 4��,E�O ���,FO��-E�O���,FO�W X  ���,FO)�l�%	+ �c��b�a	l	m�`�c 0 	formatter  �b �_	n�_ 	n  �^�]�^ 0 str  �] 0 arg  �a  	l �\�[�Z�Y�X�W�\ 0 str  �[ 0 arg  �Z 0 astid ASTID�Y 0 lst  �X 0 msg  �W 0 num  	m 
�V�U�T�S�R	o�Q:
�V 
ascr
�U 
txdl
�T 
citm
�S 
TEXT�R 0 msg  	o �P�O�N
�P 
errn�O 0 num  �N  
�Q 
errn�` F��,E�O +�g ���,FO��-E�O���,FO��&E�VO���,FO�W X  ���,FO)�l�%	, �MB�L�K	p	q�J�M 0 trim  �L �I	r�I 	r  �H�H 0 _str  �K  	p �G�F�G 0 _str  �F 0 msg  	q �E�D�C�B�Ad|�@�?�>x��=�<�
�E 
pcls
�D 
ctxt
�C 
TEXT
�B 
bool
�A 
msng
�@ 
cobj�? 0 msg  �>  �=���<  �J ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O�	- �;��:�9	s	t�8�; 
0 joiner  �: �7	u�7 	u  �6�5�6 
0 pieces  �5 	0 delim  �9  	s �4�3�2�1�0�4 
0 pieces  �3 	0 delim  �2 0 astid ASTID�1 0 emsg  �0 0 enum eNum	t �/�.��-	v�,�
�/ 
ascr
�. 
txdl�- 0 emsg  	v �+�*�)
�+ 
errn�* 0 enum eNum�)  
�, 
errn�8 4��,E�O ���,FO�%E�O���,FO�W X  ���,FO)�l�%	. �(��'�&	w	x�%�( 0 is_empty  �' �$	y�$ 	y  �#�# 0 _obj  �&  	w �"�" 0 _obj  	x �!� �
�! 
msng�  0 trim  
� 
leng�% )eflv� fY hO��  eY hO)�k+ �,j  ascr  ��ޭ