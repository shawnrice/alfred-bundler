FasdUAS 1.101.10   ��   ��    k             l     ��  ��    &  # Current Alfred-Bundler version     � 	 	 @ #   C u r r e n t   A l f r e d - B u n d l e r   v e r s i o n   
  
 j     �� �� "0 bundler_version BUNDLER_VERSION  m        �   
 d e v e l      l     ��  ��    / )# Path to Alfred-Bundler's root directory     �   R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y      j    �� �� 0 bundler_dir BUNDLER_DIR  b        b        l    ����  n        1   
 ��
�� 
psxp  l   
 ����  I   
��   
�� .earsffdralis        afdr  m    ��
�� afdrcusr   �� !��
�� 
rtyp ! m    ��
�� 
ctxt��  ��  ��  ��  ��    m     " " � # # � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r -  o    ���� "0 bundler_version BUNDLER_VERSION   $ % $ j     �� &�� 0 	cache_dir 	CACHE_DIR & b     ' ( ' b     ) * ) l    +���� + n     , - , 1    ��
�� 
psxp - l    .���� . I   �� / 0
�� .earsffdralis        afdr / m    ��
�� afdrcusr 0 �� 1��
�� 
rtyp 1 m    ��
�� 
ctxt��  ��  ��  ��  ��   * m     2 2 � 3 3 � L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - ( o    ���� "0 bundler_version BUNDLER_VERSION %  4 5 4 l     ��������  ��  ��   5  6 7 6 l     ��������  ��  ��   7  8 9 8 l      �� : ;��   :   MAIN API FUNCTION     ; � < < &   M A I N   A P I   F U N C T I O N   9  = > = l     ��������  ��  ��   >  ? @ ? i   ! $ A B A I      �������� 0 load_bundler  ��  ��   B k     / C C  D E D l      �� F G��   F � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	    G � H H�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 
 	 : r e t u r n s :   t h e   s c r i p t   o b j e c t   o f   ` A l f r e d B u n d l e r . s c p t ` 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 E  I J I l     �� K L��   K , &# Check if Alfred-Bundler is installed    L � M M L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d J  N O N Z      P Q���� P >     R S R l    
 T���� T n    
 U V U I    
�� W���� 0 _folder_exists   W  X�� X o    ���� 0 bundler_dir BUNDLER_DIR��  ��   V  f     ��  ��   S m   
 ��
�� boovtrue Q k     Y Y  Z [ Z l   �� \ ]��   \  # install it if not    ] � ^ ^ & #   i n s t a l l   i t   i f   n o t [  _�� _ n    ` a ` I    �������� 0 
_bootstrap  ��  ��   a  f    ��  ��  ��   O  b c b I   �� d��
�� .sysodelanull��� ��� nmbr d m     e e ?���������   c  f g f l   �� h i��   h ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    i � j j r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y g  k l k r    ( m n m l   & o���� o b    & p q p o    $���� 0 bundler_dir BUNDLER_DIR q m   $ % r r � s s 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��   n o      ���� 0 
as_bundler   l  t u t l  ) )�� v w��   v  # Return script object    w � x x , #   R e t u r n   s c r i p t   o b j e c t u  y�� y L   ) / z z I  ) .�� {��
�� .sysoloadscpt        file { o   ) *���� 0 
as_bundler  ��  ��   @  | } | l     ��������  ��  ��   }  ~  ~ l      �� � ���   �   AUTO-DOWNLOAD BUNDLER     � � � � .   A U T O - D O W N L O A D   B U N D L E R     � � � l     ��������  ��  ��   �  � � � i   % ( � � � I      �������� 0 
_bootstrap  ��  ��   � k     � � �  � � � l      �� � ���   � ` Z Check if bundler bash bundlet is installed and install it if not.

	:returns: ``None``

	    � � � � �   C h e c k   i f   b u n d l e r   b a s h   b u n d l e t   i s   i n s t a l l e d   a n d   i n s t a l l   i t   i f   n o t . 
 
 	 : r e t u r n s :   ` ` N o n e ` ` 
 
 	 �  � � � l     �� � ���   � " # Ask to install the Bundler    � � � � 8 #   A s k   t o   i n s t a l l   t h e   B u n d l e r �  � � � Q      � � � � n    � � � I    �������� 0 _install_confirmation  ��  ��   �  f     � R      ������
�� .ascrerr ****      � ****��  ��   � k     � �  � � � l   �� � ���   � 7 1# Cannot continue to install the bundler, so stop    � � � � b #   C a n n o t   c o n t i n u e   t o   i n s t a l l   t h e   b u n d l e r ,   s o   s t o p �  ��� � L     � � m    ��
�� boovfals��   �  � � � l   �� � ���   �  # Download the bundler    � � � � , #   D o w n l o a d   t h e   b u n d l e r �  � � � r    ) � � � J    ' � �  � � � b     � � � b     � � � m     � � � � � h h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / a r c h i v e / � o    ���� "0 bundler_version BUNDLER_VERSION � m     � � � � �  . z i p �  ��� � b    % � � � b    # � � � m     � � � � � f h t t p s : / / b i t b u c k e t . o r g / s h a w n r i c e / a l f r e d - b u n d l e r / g e t / � o    "���� "0 bundler_version BUNDLER_VERSION � m   # $ � � � � �  . z i p��   � o      ���� 0 urls URLs �  � � � l  * *�� � ���   � @ :# Save Alfred-Bundler zipfile to this location temporarily    � � � � t #   S a v e   A l f r e d - B u n d l e r   z i p f i l e   t o   t h i s   l o c a t i o n   t e m p o r a r i l y �  � � � r   * 5 � � � b   * 3 � � � l  * 1 ����� � n   * 1 � � � 1   / 1��
�� 
strq � o   * /���� 0 	cache_dir 	CACHE_DIR��  ��   � m   1 2 � � � � � , / i n s t a l l e r / b u n d l e r . z i p � o      ���� 0 _zipfile   �  � � � X   6 h ��� � � k   F c � �  � � � r   F U � � � l  F S ����� � I  F S�� ���
�� .sysoexecTEXT���     TEXT � b   F O � � � b   F M � � � b   F K � � � b   F I � � � m   F G � � � � � Z c u r l   - f s S L   - - c r e a t e - d i r s   - - c o n n e c t - t i m e o u t   5   � o   G H���� 0 _url   � m   I J � � � � �    - o   � o   K L���� 0 _zipfile   � m   M N � � � � �    & &   e c h o   $ ?��  ��  ��   � o      ���� 0 _status   �  ��� � Z  V c � ����� � =  V [ � � � o   V W���� 0 _status   � m   W Z � � � � �  0 �  S   ^ _��  ��  ��  �� 0 _url   � o   9 :���� 0 urls URLs �  � � � l  i i�� � ���   � # # Could not download the file    � � � � : #   C o u l d   n o t   d o w n l o a d   t h e   f i l e �  � � � Z  i � � ����� � >  i n � � � o   i j���� 0 _status   � m   j m � � � � �  0 � R   q }�� � �
�� .ascrerr ****      � **** � m   y | � � �   N C o u l d   n o t   d o w n l o a d   b u n d l e r   i n s t a l l   f i l e � ����
�� 
errn m   u x���� ��  ��  ��   �  l  � �����   L F# Ensure directory tree already exists for bundler to be moved into it    � � #   E n s u r e   d i r e c t o r y   t r e e   a l r e a d y   e x i s t s   f o r   b u n d l e r   t o   b e   m o v e d   i n t o   i t  n  � �	
	 I   � ������� 0 
_check_dir   �� o   � ����� 0 bundler_dir BUNDLER_DIR��  ��  
  f   � �  l  � �����   ; 5# Unzip the bundler and move it to its data directory    � j #   U n z i p   t h e   b u n d l e r   a n d   m o v e   i t   t o   i t s   d a t a   d i r e c t o r y  r   � � b   � � b   � � b   � � m   � � �  c d   l  � ���~ n   � �  1   � ��}
�} 
strq  o   � ��|�| 0 	cache_dir 	CACHE_DIR�  �~   m   � �!! �"" l ;   c d   i n s t a l l e r ;   u n z i p   - q o   b u n d l e r . z i p ;   m v   . / * / b u n d l e r   l  � �#�{�z# n   � �$%$ 1   � ��y
�y 
strq% o   � ��x�x 0 bundler_dir BUNDLER_DIR�{  �z   o      �w�w 0 _cmd   &'& I  � ��v(�u
�v .sysoexecTEXT���     TEXT( o   � ��t�t 0 _cmd  �u  ' )*) l  � ��s+,�s  + Q K# Wait until bundler is fully unzipped and written to disk before finishing   , �-- � #   W a i t   u n t i l   b u n d l e r   i s   f u l l y   u n z i p p e d   a n d   w r i t t e n   t o   d i s k   b e f o r e   f i n i s h i n g* ./. r   � �010 l  � �2�r�q2 b   � �343 o   � ��p�p 0 bundler_dir BUNDLER_DIR4 m   � �55 �66 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t�r  �q  1 o      �o�o 0 
as_bundler  / 787 V   � �9:9 I  � ��n;�m
�n .sysodelanull��� ��� nmbr; m   � �<< ?ə������m  : H   � �== l  � �>�l�k> n  � �?@? I   � ��jA�i�j 0 _path_exists  A B�hB o   � ��g�g 0 
as_bundler  �h  �i  @  f   � ��l  �k  8 CDC O  � �EFE I  � ��fG�e
�f .coredeloobj        obj G l  � �H�d�cH c   � �IJI 4   � ��bK
�b 
psxfK o   � ��a�a 0 	cache_dir 	CACHE_DIRJ m   � ��`
�` 
alis�d  �c  �e  F m   � �LL�                                                                                  MACS  alis    h  Yosemite                   ����H+     �
Finder.app                                                      P.��Z]        ����  	                CoreServices    ��#      �撝       �   �   �  2Yosemite:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    Y o s e m i t e  &System/Library/CoreServices/Finder.app  / ��  D M�_M L   � ��^�^  �_   � NON l     �]�\�[�]  �\  �[  O PQP l     �ZRS�Z  R ; 5# Function to get confirmation to install the bundler   S �TT j #   F u n c t i o n   t o   g e t   c o n f i r m a t i o n   t o   i n s t a l l   t h e   b u n d l e rQ UVU i   ) ,WXW I      �Y�X�W�Y 0 _install_confirmation  �X  �W  X k     �YY Z[Z l      �V\]�V  \ � � Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	   ] �^^V   A s k   u s e r   f o r   p e r m i s s i o n   t o   i n s t a l l   A l f r e d - B u n d l e r .   
 	 A l l o w   u s e r   t o   g o   t o   w e b s i t e   f o r   m o r e   i n f o r m a t i o n ,   o r   e v e n   t o   c a n c e l   d o w n l o a d . 
 
 	 : r e t u r n s :   ` ` T r u e ` `   o r   r a i s e s   E r r o r 
 
 	[ _`_ l     �Uab�U  a 0 *# Get path to workflow's `info.plist` file   b �cc T #   G e t   p a t h   t o   w o r k f l o w ' s   ` i n f o . p l i s t `   f i l e` ded r     	fgf b     hih n    jkj I    �T�S�R�T 0 _pwd  �S  �R  k  f     i m    ll �mm  i n f o . p l i s tg o      �Q�Q 
0 _plist  e non l  
 
�Ppq�P  p 5 /# Get name of workflow's from `info.plist` file   q �rr ^ #   G e t   n a m e   o f   w o r k f l o w ' s   f r o m   ` i n f o . p l i s t `   f i l eo sts r   
 uvu b   
 wxw b   
 yzy m   
 {{ �|| T / u s r / l i b e x e c / P l i s t B u d d y   - c   ' P r i n t   : n a m e '   'z o    �O�O 
0 _plist  x m    }} �~~  'v o      �N�N 0 _cmd  t � r    ��� I   �M��L
�M .sysoexecTEXT���     TEXT� o    �K�K 0 _cmd  �L  � o      �J�J 	0 _name  � ��� l   �I���I  � 6 0# Get workflow's icon, or default to system icon   � ��� ` #   G e t   w o r k f l o w ' s   i c o n ,   o r   d e f a u l t   t o   s y s t e m   i c o n� ��� r    #��� b    !��� n   ��� I    �H�G�F�H 0 _pwd  �G  �F  �  f    � m     �� ���  i c o n . p n g� o      �E�E 	0 _icon  � ��� r   $ ,��� n  $ *��� I   % *�D��C�D 0 _check_icon  � ��B� o   % &�A�A 	0 _icon  �B  �C  �  f   $ %� o      �@�@ 	0 _icon  � ��� l  - -�?���?  � / )# Prepare explanation text for dialog box   � ��� R #   P r e p a r e   e x p l a n a t i o n   t e x t   f o r   d i a l o g   b o x� ��� r   - 6��� b   - 4��� b   - 2��� b   - 0��� o   - .�>�> 	0 _name  � m   . /�� ���   n e e d s   t o   i n s t a l l   a d d i t i o n a l   c o m p o n e n t s ,   w h i c h   w i l l   b e   p l a c e d   i n   t h e   A l f r e d   s t o r a g e   d i r e c t o r y   a n d   w i l l   n o t   i n t e r f e r e   w i t h   y o u r   s y s t e m . 
 
 Y o u   m a y   b e   a s k e d   t o   a l l o w   s o m e   c o m p o n e n t s   t o   r u n ,   d e p e n d i n g   o n   y o u r   s e c u r i t y   s e t t i n g s . 
 
 Y o u   c a n   d e c l i n e   t h i s   i n s t a l l a t i o n ,   b u t  � o   0 1�=�= 	0 _name  � m   2 3�� ��� �   m a y   n o t   w o r k   w i t h o u t   t h e m .   T h e r e   w i l l   b e   a   s l i g h t   d e l a y   a f t e r   a c c e p t i n g .� o      �<�< 	0 _text  � ��� l  7 7�;�:�9�;  �:  �9  � ��� r   7 Y��� n   7 W��� 1   S W�8
�8 
bhit� l  7 S��7�6� I  7 S�5��
�5 .sysodlogaskr        TEXT� o   7 8�4�4 	0 _text  � �3��
�3 
btns� J   9 >�� ��� m   9 :�� ���  M o r e   I n f o� ��� m   : ;�� ���  C a n c e l� ��2� m   ; <�� ���  P r o c e e d�2  � �1��
�1 
dflt� m   ? @�0�0 � �/��
�/ 
appr� b   A D��� m   A B�� ���  S e t u p  � o   B C�.�. 	0 _name  � �-��,
�- 
disp� 4   G M�+�
�+ 
psxf� o   K L�*�* 	0 _icon  �,  �7  �6  � o      �)�) 0 	_response  � ��� l  Z Z�(���(  � 0 *# If permission granted, continue download   � ��� T #   I f   p e r m i s s i o n   g r a n t e d ,   c o n t i n u e   d o w n l o a d� ��� Z  Z h���'�&� =  Z _��� o   Z [�%�% 0 	_response  � m   [ ^�� ���  P r o c e e d� L   b d�� m   b c�$
�$ boovtrue�'  �&  � ��� l  i i�#���#  � 6 0# If more info requested, open webpage and error   � ��� ` #   I f   m o r e   i n f o   r e q u e s t e d ,   o p e n   w e b p a g e   a n d   e r r o r� ��� Z   i ����"�!� =  i n��� o   i j� �  0 	_response  � m   j m�� ���  M o r e   I n f o� k   q ��� ��� O   q ��� I  w ~���
� .GURLGURLnull��� ��� TEXT� m   w z�� ��� � h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / w i k i / W h a t - i s - t h e - A l f r e d - B u n d l e r�  � m   q t���                                                                                  sevs  alis    �  Yosemite                   ����H+     �System Events.app                                               	���^V        ����  	                CoreServices    ��#      �斖       �   �   �  9Yosemite:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    Y o s e m i t e  -System/Library/CoreServices/System Events.app   / ��  � ��� R   � ����
� .ascrerr ****      � ****� m   � ��� ��� F U s e r   l o o k e d   s o u g h t   m o r e   i n f o r m a t i o n� ���
� 
errn� m   � ��� �  �  �"  �!  � ��� l  � �����  � , &# If permission denied, stop and error   � ��� L #   I f   p e r m i s s i o n   d e n i e d ,   s t o p   a n d   e r r o r�  �  Z  � ��� =  � � o   � ��� 0 	_response   m   � � �  C a n c e l R   � ��
� .ascrerr ****      � **** m   � �		 �

 D U s e r   c a n c e l e d   b u n d l e r   i n s t a l l a t i o n ��
� 
errn m   � ��� �  �  �  �  V  l     ����  �  �    l     ���
�  �  �
    l      �	�	     HELPER HANDLERS     � "   H E L P E R   H A N D L E R S    l     ����  �  �    i   - 0 I      ���� 0 _pwd  �  �   k     8  l      ��   � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	    �  J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	 !"! l     �#$�  # = 7# Save default AS delimiters, and set delimiters to "/"   $ �%% n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / "" &'& r     ()( J     ** +,+ n    -.- 1    � 
�  
txdl. 1     ��
�� 
ascr, /��/ m    00 �11  /��  ) J      22 343 o      ���� 0 astid ASTID4 5��5 n     676 1    ��
�� 
txdl7 1    ��
�� 
ascr��  ' 898 l   ��:;��  : , &# Get POSIX path of script's directory   ; �<< L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r y9 =>= r    /?@? b    -ABA l   +C����C c    +DED n    )FGF 7   )��HI
�� 
citmH m   # %���� I m   & (������G l   J����J n    KLK 1    ��
�� 
psxpL l   M����M I   ��N��
�� .earsffdralis        afdrN  f    ��  ��  ��  ��  ��  E m   ) *��
�� 
TEXT��  ��  B m   + ,OO �PP  /@ o      ���� 	0 _path  > QRQ l  0 0��ST��  S . (# Reset AS delimiters to original values   T �UU P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e sR VWV r   0 5XYX o   0 1���� 0 astid ASTIDY n     Z[Z 1   2 4��
�� 
txdl[ 1   1 2��
�� 
ascrW \��\ L   6 8]] o   6 7���� 	0 _path  ��   ^_^ l     ��������  ��  ��  _ `a` i   1 4bcb I      ��d���� 0 _prepare_cmd  d e��e o      ���� 0 _cmd  ��  ��  c k     ff ghg l      ��ij��  i,& Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:rtype: ``string``
		
	   j �kkL   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r t y   d i r e c t o r y . 
 	 F o r   t e s t i n g   p u r p o s e s ,   i t   a l s o   s e t s   t h e   ` A B _ B R A N C H `   e n v i r o n m e n t a l   v a r i a b l e . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	h lml l     ��no��  n 9 3# Ensure `pwd` is properly quoted for shell command   o �pp f #   E n s u r e   ` p w d `   i s   p r o p e r l y   q u o t e d   f o r   s h e l l   c o m m a n dm qrq r     	sts n     uvu 1    ��
�� 
strqv l    w����w n    xyx I    �������� 0 _pwd  ��  ��  y  f     ��  ��  t o      ���� 0 pwd  r z{z l  
 
��|}��  | &  # Declare environmental variable   } �~~ @ #   D e c l a r e   e n v i r o n m e n t a l   v a r i a b l e{ � l  
 
������  � % #TODO: remove for final release   � ��� > # T O D O :   r e m o v e   f o r   f i n a l   r e l e a s e� ��� r   
 ��� m   
 �� ��� 0 e x p o r t   A B _ B R A N C H = d e v e l ;  � o      ���� 0 testing_var  � ��� l   ������  � 7 1# return shell script where `pwd` is properly set   � ��� b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t� ���� L    �� b    ��� b    ��� b    ��� b    ��� o    ���� 0 testing_var  � m    �� ���  c d  � o    ���� 0 pwd  � m    �� ���  ;   b a s h  � o    ���� 0 _cmd  ��  a ��� l     ��������  ��  ��  � ��� i   5 8��� I      ������� 0 _check_icon  � ���� o      ���� 	0 _icon  ��  ��  � k     �� ��� l      ������  � � � Check if `_icon` exists, and if not revert to system download icon.

	:returns: POSIX path to `_icon`
	:rtype: ``string`` (POSIX path)

	   � ���   C h e c k   i f   ` _ i c o n `   e x i s t s ,   a n d   i f   n o t   r e v e r t   t o   s y s t e m   d o w n l o a d   i c o n . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ i c o n ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ���� Q     ���� k    �� ��� c    	��� 4    ���
�� 
psxf� o    ���� 	0 _icon  � m    ��
�� 
alis� ���� L   
 �� o   
 ���� 	0 _icon  ��  � R      ������
�� .ascrerr ****      � ****��  ��  � L    �� m    �� ��� � / S y s t e m / L i b r a r y / C o r e S e r v i c e s / C o r e T y p e s . b u n d l e / C o n t e n t s / R e s o u r c e s / S i d e b a r D o w n l o a d s F o l d e r . i c n s��  � ��� l     ��������  ��  ��  � ��� i   9 <��� I      ������� 0 
_check_dir  � ���� o      ���� 0 _folder  ��  ��  � k     �� ��� l      ������  � � � Check if `_folder` exists, and if not create it, including any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	   � ���0   C h e c k   i f   ` _ f o l d e r `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t ,   i n c l u d i n g   a n y   s u b - d i r e c t o r i e s . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ f o l d e r ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ��� Z     ������� H     �� n    ��� I    ������� 0 _folder_exists  � ���� o    ���� 0 _folder  ��  ��  �  f     � I  
 �����
�� .sysoexecTEXT���     TEXT� b   
 ��� m   
 �� ���  m k d i r   - p  � l   ������ n    ��� 1    ��
�� 
strq� o    ���� 0 _folder  ��  ��  ��  ��  ��  � ���� L    �� o    ���� 0 _folder  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� i   = @��� I      ������� 0 _folder_exists  � ���� o      ���� 0 _folder  ��  ��  � k     �� ��� l      ������  � � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	   � ���>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	� ��� Z     ������� n    ��� I    ������� 0 _path_exists  � ���� o    ���� 0 _folder  ��  ��  �  f     � O   	 ��� L    �� l   ������ =   ��� n    ��� m    ��
�� 
pcls� l   ������ 4    ���
�� 
ditm� o    ���� 0 _folder  ��  ��  � m    ��
�� 
cfol��  ��  � m   	 
���                                                                                  sevs  alis    �  Yosemite                   ����H+     �System Events.app                                               	���^V        ����  	                CoreServices    ��#      �斖       �   �   �  9Yosemite:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    Y o s e m i t e  -System/Library/CoreServices/System Events.app   / ��  ��  ��  � ���� L    �� m    ��
�� boovfals��  �    l     ��������  ��  ��    i   A D I      ������ 0 _path_exists   �� o      ���� 	0 _path  ��  ��   k     Y 	
	 l      ����   � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	
  Z    ���� G      =     o     ���� 	0 _path   m    �
� 
msng n    I    �~�}�~ 0 	_is_empty   �| o    �{�{ 	0 _path  �|  �}    f     L     m    �z
�z boovfals��  ��   �y Q    Y k    O  !  Z   )"#�x�w" =    $%$ n    &'& m    �v
�v 
pcls' o    �u�u 	0 _path  % m    �t
�t 
alis# L   # %(( m   # $�s
�s boovtrue�x  �w  ! )�r) Z   * O*+,-* E   * -./. o   * +�q�q 	0 _path  / m   + ,00 �11  :+ k   0 822 343 4   0 5�p5
�p 
alis5 o   2 3�o�o 	0 _path  4 6�n6 L   6 877 m   6 7�m
�m boovtrue�n  , 898 E   ; >:;: o   ; <�l�l 	0 _path  ; m   < =<< �==  /9 >�k> k   A J?? @A@ c   A GBCB 4   A E�jD
�j 
psxfD o   C D�i�i 	0 _path  C m   E F�h
�h 
alisA E�gE L   H JFF m   H I�f
�f boovtrue�g  �k  - L   M OGG m   M N�e
�e boovfals�r   R      �dH�c
�d .ascrerr ****      � ****H o      �b�b 0 msg  �c   L   W YII m   W X�a
�a boovfals�y   JKJ l     �`�_�^�`  �_  �^  K LML i   E HNON I      �]P�\�] 0 	_is_empty  P Q�[Q o      �Z�Z 0 _obj  �[  �\  O k     (RR STS l      �YUV�Y  U � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:returns: ``Boolean``
		
	   V �WW   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
 	T XYX l     �XZ[�X  Z ! # Is `_obj ` a ``Boolean``?   [ �\\ 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?Y ]^] Z    _`�W�V_ E     aba J     cc ded m     �U
�U boovtruee f�Tf m    �S
�S boovfals�T  b o    �R�R 0 _obj  ` L   	 gg m   	 
�Q
�Q boovfals�W  �V  ^ hih l   �Pjk�P  j ' !# Is `_obj ` a ``missing value``?   k �ll B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?i mnm Z   op�O�No =   qrq o    �M�M 0 _obj  r m    �L
�L 
msngp L    ss m    �K
�K boovtrue�O  �N  n tut l   �Jvw�J  v " # Is `_obj ` a empty string?   w �xx 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?u y�Iy L    (zz =   '{|{ n    %}~} 1   # %�H
�H 
leng~ l   #�G�F n   #��� I    #�E��D�E 	0 _trim  � ��C� o    �B�B 0 _obj  �C  �D  �  f    �G  �F  | m   % &�A�A  �I  M ��� l     �@�?�>�@  �?  �>  � ��=� i   I L��� I      �<��;�< 	0 _trim  � ��:� o      �9�9 0 _str  �:  �;  � k     ��� ��� l      �8���8  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string

	   � ���   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 
 	� ��� Z     ���7�6� G     ��� G     ��� >    ��� n     ��� m    �5
�5 
pcls� o     �4�4 0 _str  � m    �3
�3 
ctxt� >   ��� n    ��� m   	 �2
�2 
pcls� o    	�1�1 0 _str  � m    �0
�0 
TEXT� =   ��� o    �/�/ 0 _str  � m    �.
�. 
msng� L    �� o    �-�- 0 _str  �7  �6  � ��� Z  ! -���,�+� =  ! $��� o   ! "�*�* 0 _str  � m   " #�� ���  � L   ' )�� o   ' (�)�) 0 _str  �,  �+  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D�(��
�( 
cobj� m   > @�'�' � m   A C�&�&��� o   9 :�%�% 0 _str  � m   D E�$
�$ 
ctxt� o      �#�# 0 _str  � R      �"��!
�" .ascrerr ****      � ****� o      � �  0 msg  �!  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�� 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n���
� 
cobj� m   h j�� � m   k m����� o   c d�� 0 _str  � m   n o�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****�  �  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�� 0 _str  � m   ] ^�� ���   � ��� L   � ��� o   � ��� 0 _str  �  �=       �� ��������������  � ��������
�	������ "0 bundler_version BUNDLER_VERSION� 0 bundler_dir BUNDLER_DIR� 0 	cache_dir 	CACHE_DIR� 0 load_bundler  � 0 
_bootstrap  � 0 _install_confirmation  � 0 _pwd  �
 0 _prepare_cmd  �	 0 _check_icon  � 0 
_check_dir  � 0 _folder_exists  � 0 _path_exists  � 0 	_is_empty  � 	0 _trim  � ��� � / U s e r s / m a r g h e i m / L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - d e v e l� ��� � / U s e r s / m a r g h e i m / L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - d e v e l� � B����� � 0 load_bundler  �  �  � ���� 0 
as_bundler  � ���� e�� r���� 0 _folder_exists  �� 0 
_bootstrap  
�� .sysodelanull��� ��� nmbr
�� .sysoloadscpt        file�  0)b  k+  e 
)j+ Y hO�j Ob  �%E�O�j � �� ����������� 0 
_bootstrap  ��  ��  � �������������� 0 urls URLs�� 0 _zipfile  �� 0 _url  �� 0 _status  �� 0 _cmd  �� 0 
as_bundler  �  ������ � � � ��� ������� � � ��� � ����� ���!5��<��L�������� 0 _install_confirmation  ��  ��  
�� 
strq
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� .sysoexecTEXT���     TEXT
�� 
errn�� �� 0 
_check_dir  �� 0 _path_exists  
�� .sysodelanull��� ��� nmbr
�� 
psxf
�� 
alis
�� .coredeloobj        obj �� � 
)j+  W 	X  fO�b   %�%�b   %�%lvE�Ob  �,�%E�O 1�[��l kh �%�%�%�%j E�O�a   Y h[OY��O�a  )a a la Y hO)b  k+ Oa b  �,%a %b  �,%E�O�j Ob  a %E�O h)�k+ a j [OY��Oa  *a b  /a &j UOh� ��X���������� 0 _install_confirmation  ��  ��  � �������������� 
0 _plist  �� 0 _cmd  �� 	0 _name  �� 	0 _icon  �� 	0 _text  �� 0 	_response  � ��l{}��������������������������������������	�� 0 _pwd  
�� .sysoexecTEXT���     TEXT�� 0 _check_icon  
�� 
btns
�� 
dflt
�� 
appr
�� 
disp
�� 
psxf�� 
�� .sysodlogaskr        TEXT
�� 
bhit
�� .GURLGURLnull��� ��� TEXT
�� 
errn�� �� �)j+  �%E�O�%�%E�O�j E�O)j+  �%E�O)�k+ E�O��%�%�%E�O�����mv�m��%a *a �/a  a ,E�O�a   eY hO�a    a  	a j UO)a a la Y hO�a   )a a la Y h� ������������ 0 _pwd  ��  ��  � ������ 0 astid ASTID�� 	0 _path  � 
����0������������O
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�� ��c���������� 0 _prepare_cmd  �� ����� �  ���� 0 _cmd  ��  � �������� 0 _cmd  �� 0 pwd  �� 0 testing_var  � ��������� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�%� ������������� 0 _check_icon  �� ����� �  ���� 	0 _icon  ��  � ���� 	0 _icon  � ���������
�� 
psxf
�� 
alis��  ��  ��  *�/�&O�W 	X  �� ������������� 0 
_check_dir  �� ����� �  ���� 0 _folder  ��  � ���� 0 _folder  � ��������� 0 _folder_exists  
�� 
strq
�� .sysoexecTEXT���     TEXT�� )�k+   ��,%j Y hO�� ������������� 0 _folder_exists  �� ����� �  ���� 0 _folder  ��  � ���� 0 _folder  � ����������� 0 _path_exists  
�� 
ditm
�� 
pcls
�� 
cfol�� )�k+   � *�/�,� UY hOf� ������ ���� 0 _path_exists  �� ����   ���� 	0 _path  ��    ������ 	0 _path  �� 0 msg   
����������0<������
�� 
msng�� 0 	_is_empty  
�� 
bool
�� 
pcls
�� 
alis
�� 
psxf�� 0 msg  ��  �� Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f� �O�~�}�|� 0 	_is_empty  �~ �{�{   �z�z 0 _obj  �}   �y�y 0 _obj   �x�w�v
�x 
msng�w 	0 _trim  
�v 
leng�| )eflv� fY hO��  eY hO)�k+ �,j � �u��t�s�r�u 	0 _trim  �t �q�q   �p�p 0 _str  �s   �o�n�o 0 _str  �n 0 msg   �m�l�k�j�i���h�g�f���e�d�
�m 
pcls
�l 
ctxt
�k 
TEXT
�j 
bool
�i 
msng
�h 
cobj�g 0 msg  �f  �e���d  �r ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O�ascr  ��ޭ