FasdUAS 1.101.10   ��   ��    k             l     ��  ��    &  # Current Alfred-Bundler version     � 	 	 @ #   C u r r e n t   A l f r e d - B u n d l e r   v e r s i o n   
  
 j     �� �� "0 bundler_version BUNDLER_VERSION  m        �   
 d e v e l      l     ��  ��    % # Path to user's home directory     �   > #   P a t h   t o   u s e r ' s   h o m e   d i r e c t o r y      j    �� �� 	0 _home    n        1   
 ��
�� 
psxp  l   
 ����  I   
��  
�� .earsffdralis        afdr  m       �    c u s r  �� ��
�� 
rtyp  m    ��
�� 
ctxt��  ��  ��         l     �� ! "��   ! / )# Path to Alfred-Bundler's root directory    " � # # R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y    $ % $ j    �� &�� 0 bundler_dir BUNDLER_DIR & b     ' ( ' b     ) * ) l    +���� + o    ���� 	0 _home  ��  ��   * m     , , � - - � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - ( o    ���� "0 bundler_version BUNDLER_VERSION %  . / . j    �� 0�� 0 	cache_dir 	CACHE_DIR 0 b     1 2 1 b     3 4 3 l    5���� 5 o    ���� 	0 _home  ��  ��   4 m     6 6 � 7 7 � L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - 2 o    ���� "0 bundler_version BUNDLER_VERSION /  8 9 8 l     ��������  ��  ��   9  : ; : l     ��������  ��  ��   ;  < = < l      �� > ?��   >   MAIN API FUNCTION     ? � @ @ &   M A I N   A P I   F U N C T I O N   =  A B A l     ��������  ��  ��   B  C D C i      E F E I      �������� 0 load_bundler  ��  ��   F k     / G G  H I H l      �� J K��   J � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	    K � L L�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 
 	 : r e t u r n s :   t h e   s c r i p t   o b j e c t   o f   ` A l f r e d B u n d l e r . s c p t ` 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 I  M N M l     �� O P��   O , &# Check if Alfred-Bundler is installed    P � Q Q L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d N  R S R Z      T U���� T >     V W V l    
 X���� X n    
 Y Z Y I    
�� [���� 0 _folder_exists   [  \�� \ o    ���� 0 bundler_dir BUNDLER_DIR��  ��   Z  f     ��  ��   W m   
 ��
�� boovtrue U k     ] ]  ^ _ ^ l   �� ` a��   `  # install it if not    a � b b & #   i n s t a l l   i t   i f   n o t _  c�� c n    d e d I    �������� 0 
_bootstrap  ��  ��   e  f    ��  ��  ��   S  f g f I   �� h��
�� .sysodelanull��� ��� nmbr h m     i i ?���������   g  j k j l   �� l m��   l ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    m � n n r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y k  o p o r    ( q r q l   & s���� s b    & t u t o    $���� 0 bundler_dir BUNDLER_DIR u m   $ % v v � w w 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��   r o      ���� 0 
as_bundler   p  x y x l  ) )�� z {��   z  # Return script object    { � | | , #   R e t u r n   s c r i p t   o b j e c t y  }�� } L   ) / ~ ~ I  ) .�� ��
�� .sysoloadscpt        file  o   ) *���� 0 
as_bundler  ��  ��   D  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   AUTO-DOWNLOAD BUNDLER     � � � � .   A U T O - D O W N L O A D   B U N D L E R   �  � � � l     ��������  ��  ��   �  � � � i   ! $ � � � I      �������� 0 
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
�� .sysoexecTEXT���     TEXT � b   F O � � � b   F M � � � b   F K � � � b   F I � � � m   F G � � � � � Z c u r l   - f s S L   - - c r e a t e - d i r s   - - c o n n e c t - t i m e o u t   5   � o   G H���� 0 _url   � m   I J � � � � �    - o   � o   K L���� 0 _zipfile   � m   M N � � � � �    & &   e c h o   $ ?��  ��  ��   � o      ���� 0 _status   �  ��� � Z  V c � ����� � =  V [ � � � o   V W���� 0 _status   � m   W Z � � � � �  0 �  S   ^ _��  ��  ��  �� 0 _url   � o   9 :���� 0 urls URLs �  � � � l  i i�� � ���   � # # Could not download the file    � � � � : #   C o u l d   n o t   d o w n l o a d   t h e   f i l e �  � � � Z  i � � ����� � >  i n � � � o   i j���� 0 _status   � m   j m � � �    0 � R   q }��
�� .ascrerr ****      � **** m   y | � N C o u l d   n o t   d o w n l o a d   b u n d l e r   i n s t a l l   f i l e ����
�� 
errn m   u x���� ��  ��  ��   �  l  � ���	��   L F# Ensure directory tree already exists for bundler to be moved into it   	 �

 � #   E n s u r e   d i r e c t o r y   t r e e   a l r e a d y   e x i s t s   f o r   b u n d l e r   t o   b e   m o v e d   i n t o   i t  n  � � I   � ������� 0 
_check_dir   �� o   � ����� 0 bundler_dir BUNDLER_DIR��  ��    f   � �  l  � �����   ; 5# Unzip the bundler and move it to its data directory    � j #   U n z i p   t h e   b u n d l e r   a n d   m o v e   i t   t o   i t s   d a t a   d i r e c t o r y  r   � � b   � � b   � � b   � � m   � �   �!!  c d   l  � �"����" n   � �#$# 1   � ���
�� 
strq$ o   � ����� 0 	cache_dir 	CACHE_DIR��  ��   m   � �%% �&& l ;   c d   i n s t a l l e r ;   u n z i p   - q o   b u n d l e r . z i p ;   m v   . / * / b u n d l e r   l  � �'���' n   � �()( 1   � ��~
�~ 
strq) o   � ��}�} 0 bundler_dir BUNDLER_DIR��  �   o      �|�| 0 _cmd   *+* I  � ��{,�z
�{ .sysoexecTEXT���     TEXT, o   � ��y�y 0 _cmd  �z  + -.- l  � ��x/0�x  / Q K# Wait until bundler is fully unzipped and written to disk before finishing   0 �11 � #   W a i t   u n t i l   b u n d l e r   i s   f u l l y   u n z i p p e d   a n d   w r i t t e n   t o   d i s k   b e f o r e   f i n i s h i n g. 232 r   � �454 l  � �6�w�v6 b   � �787 o   � ��u�u 0 bundler_dir BUNDLER_DIR8 m   � �99 �:: 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t�w  �v  5 o      �t�t 0 
as_bundler  3 ;<; V   � �=>= I  � ��s?�r
�s .sysodelanull��� ��� nmbr? m   � �@@ ?ə������r  > H   � �AA l  � �B�q�pB n  � �CDC I   � ��oE�n�o 0 _path_exists  E F�mF o   � ��l�l 0 
as_bundler  �m  �n  D  f   � ��q  �p  < GHG O  � �IJI I  � ��kK�j
�k .coredeloobj        obj K l  � �L�i�hL c   � �MNM 4   � ��gO
�g 
psxfO o   � ��f�f 0 	cache_dir 	CACHE_DIRN m   � ��e
�e 
alis�i  �h  �j  J m   � �PP�                                                                                  MACS  alis    t  Macintosh HD               ����H+  ҍK
Finder.app                                                     ԲY�`�        ����  	                CoreServices    ���*      �`D    ҍKҍHҍG  6Macintosh HD:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  H Q�dQ L   � ��c�c  �d   � RSR l     �b�a�`�b  �a  �`  S TUT l     �_VW�_  V ; 5# Function to get confirmation to install the bundler   W �XX j #   F u n c t i o n   t o   g e t   c o n f i r m a t i o n   t o   i n s t a l l   t h e   b u n d l e rU YZY i   % ([\[ I      �^�]�\�^ 0 _install_confirmation  �]  �\  \ k     �]] ^_^ l      �[`a�[  ` � � Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	   a �bbV   A s k   u s e r   f o r   p e r m i s s i o n   t o   i n s t a l l   A l f r e d - B u n d l e r .   
 	 A l l o w   u s e r   t o   g o   t o   w e b s i t e   f o r   m o r e   i n f o r m a t i o n ,   o r   e v e n   t o   c a n c e l   d o w n l o a d . 
 
 	 : r e t u r n s :   ` ` T r u e ` `   o r   r a i s e s   E r r o r 
 
 	_ cdc l     �Zef�Z  e 0 *# Get path to workflow's `info.plist` file   f �gg T #   G e t   p a t h   t o   w o r k f l o w ' s   ` i n f o . p l i s t `   f i l ed hih r     	jkj b     lml n    non I    �Y�X�W�Y 0 _pwd  �X  �W  o  f     m m    pp �qq  i n f o . p l i s tk o      �V�V 
0 _plist  i rsr l  
 
�Utu�U  t 5 /# Get name of workflow's from `info.plist` file   u �vv ^ #   G e t   n a m e   o f   w o r k f l o w ' s   f r o m   ` i n f o . p l i s t `   f i l es wxw r   
 yzy b   
 {|{ b   
 }~} m   
  ��� T / u s r / l i b e x e c / P l i s t B u d d y   - c   ' P r i n t   : n a m e '   '~ o    �T�T 
0 _plist  | m    �� ���  'z o      �S�S 0 _cmd  x ��� r    ��� I   �R��Q
�R .sysoexecTEXT���     TEXT� o    �P�P 0 _cmd  �Q  � o      �O�O 	0 _name  � ��� l   �N���N  � 6 0# Get workflow's icon, or default to system icon   � ��� ` #   G e t   w o r k f l o w ' s   i c o n ,   o r   d e f a u l t   t o   s y s t e m   i c o n� ��� r    #��� b    !��� n   ��� I    �M�L�K�M 0 _pwd  �L  �K  �  f    � m     �� ���  i c o n . p n g� o      �J�J 	0 _icon  � ��� r   $ ,��� n  $ *��� I   % *�I��H�I 0 _check_icon  � ��G� o   % &�F�F 	0 _icon  �G  �H  �  f   $ %� o      �E�E 	0 _icon  � ��� l  - -�D���D  � / )# Prepare explanation text for dialog box   � ��� R #   P r e p a r e   e x p l a n a t i o n   t e x t   f o r   d i a l o g   b o x� ��� r   - 6��� b   - 4��� b   - 2��� b   - 0��� o   - .�C�C 	0 _name  � m   . /�� ���   n e e d s   t o   i n s t a l l   a d d i t i o n a l   c o m p o n e n t s ,   w h i c h   w i l l   b e   p l a c e d   i n   t h e   A l f r e d   s t o r a g e   d i r e c t o r y   a n d   w i l l   n o t   i n t e r f e r e   w i t h   y o u r   s y s t e m . 
 
 Y o u   m a y   b e   a s k e d   t o   a l l o w   s o m e   c o m p o n e n t s   t o   r u n ,   d e p e n d i n g   o n   y o u r   s e c u r i t y   s e t t i n g s . 
 
 Y o u   c a n   d e c l i n e   t h i s   i n s t a l l a t i o n ,   b u t  � o   0 1�B�B 	0 _name  � m   2 3�� ��� �   m a y   n o t   w o r k   w i t h o u t   t h e m .   T h e r e   w i l l   b e   a   s l i g h t   d e l a y   a f t e r   a c c e p t i n g .� o      �A�A 	0 _text  � ��� l  7 7�@�?�>�@  �?  �>  � ��� r   7 Y��� n   7 W��� 1   S W�=
�= 
bhit� l  7 S��<�;� I  7 S�:��
�: .sysodlogaskr        TEXT� o   7 8�9�9 	0 _text  � �8��
�8 
btns� J   9 >�� ��� m   9 :�� ���  M o r e   I n f o� ��� m   : ;�� ���  C a n c e l� ��7� m   ; <�� ���  P r o c e e d�7  � �6��
�6 
dflt� m   ? @�5�5 � �4��
�4 
appr� b   A D��� m   A B�� ���  S e t u p  � o   B C�3�3 	0 _name  � �2��1
�2 
disp� 4   G M�0�
�0 
psxf� o   K L�/�/ 	0 _icon  �1  �<  �;  � o      �.�. 0 	_response  � ��� l  Z Z�-���-  � 0 *# If permission granted, continue download   � ��� T #   I f   p e r m i s s i o n   g r a n t e d ,   c o n t i n u e   d o w n l o a d� ��� Z  Z h���,�+� =  Z _��� o   Z [�*�* 0 	_response  � m   [ ^�� ���  P r o c e e d� L   b d�� m   b c�)
�) boovtrue�,  �+  � ��� l  i i�(���(  � 6 0# If more info requested, open webpage and error   � ��� ` #   I f   m o r e   i n f o   r e q u e s t e d ,   o p e n   w e b p a g e   a n d   e r r o r� ��� Z   i ����'�&� =  i n��� o   i j�%�% 0 	_response  � m   j m�� ���  M o r e   I n f o� k   q ��� ��� O   q ��� I  w ~�$��#
�$ .GURLGURLnull��� ��� TEXT� m   w z�� ��� � h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / w i k i / W h a t - i s - t h e - A l f r e d - B u n d l e r�#  � m   q t���                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  � ��"� R   � ��!��
�! .ascrerr ****      � ****� m   � ��� ��� F U s e r   l o o k e d   s o u g h t   m o r e   i n f o r m a t i o n� � ��
�  
errn� m   � ��� �  �"  �'  �&  � � � l  � ���   , &# If permission denied, stop and error    � L #   I f   p e r m i s s i o n   d e n i e d ,   s t o p   a n d   e r r o r  � Z  � ��� =  � � o   � ��� 0 	_response   m   � �		 �

  C a n c e l R   � ��
� .ascrerr ****      � **** m   � � � 4 U s e r   c a n c e l e d   i n s t a l l a t i o n ��
� 
errn m   � ��� �  �  �  �  Z  l     ����  �  �    l     ����  �  �    l      ��     HELPER HANDLERS     � "   H E L P E R   H A N D L E R S    l     ����  �  �    i   ) , I      �
�	��
 0 _pwd  �	  �   k     8  !  l      �"#�  " � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   # �$$J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	! %&% l     �'(�  ' = 7# Save default AS delimiters, and set delimiters to "/"   ( �)) n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / "& *+* r     ,-, J     .. /0/ n    121 1    �
� 
txdl2 1     �
� 
ascr0 3�3 m    44 �55  /�  - J      66 787 o      �� 0 astid ASTID8 9�9 n     :;: 1    � 
�  
txdl; 1    ��
�� 
ascr�  + <=< l   ��>?��  > , &# Get POSIX path of script's directory   ? �@@ L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r y= ABA r    /CDC b    -EFE l   +G����G c    +HIH n    )JKJ 7   )��LM
�� 
citmL m   # %���� M m   & (������K l   N����N n    OPO 1    ��
�� 
psxpP l   Q����Q I   ��R��
�� .earsffdralis        afdrR  f    ��  ��  ��  ��  ��  I m   ) *��
�� 
TEXT��  ��  F m   + ,SS �TT  /D o      ���� 	0 _path  B UVU l  0 0��WX��  W . (# Reset AS delimiters to original values   X �YY P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e sV Z[Z r   0 5\]\ o   0 1���� 0 astid ASTID] n     ^_^ 1   2 4��
�� 
txdl_ 1   1 2��
�� 
ascr[ `��` L   6 8aa o   6 7���� 	0 _path  ��   bcb l     ��������  ��  ��  c ded i   - 0fgf I      ��h���� 0 _prepare_cmd  h i��i o      ���� 0 _cmd  ��  ��  g k     jj klk l      ��mn��  m,& Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:rtype: ``string``
		
	   n �ooL   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r t y   d i r e c t o r y . 
 	 F o r   t e s t i n g   p u r p o s e s ,   i t   a l s o   s e t s   t h e   ` A B _ B R A N C H `   e n v i r o n m e n t a l   v a r i a b l e . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	l pqp l     ��rs��  r 9 3# Ensure `pwd` is properly quoted for shell command   s �tt f #   E n s u r e   ` p w d `   i s   p r o p e r l y   q u o t e d   f o r   s h e l l   c o m m a n dq uvu r     	wxw n     yzy 1    ��
�� 
strqz l    {����{ n    |}| I    �������� 0 _pwd  ��  ��  }  f     ��  ��  x o      ���� 0 pwd  v ~~ l  
 
������  � &  # Declare environmental variable   � ��� @ #   D e c l a r e   e n v i r o n m e n t a l   v a r i a b l e ��� l  
 
������  � % #TODO: remove for final release   � ��� > # T O D O :   r e m o v e   f o r   f i n a l   r e l e a s e� ��� r   
 ��� m   
 �� ��� 0 e x p o r t   A B _ B R A N C H = d e v e l ;  � o      ���� 0 testing_var  � ��� l   ������  � 7 1# return shell script where `pwd` is properly set   � ��� b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t� ���� L    �� b    ��� b    ��� b    ��� b    ��� o    ���� 0 testing_var  � m    �� ���  c d  � o    ���� 0 pwd  � m    �� ���  ;   b a s h  � o    ���� 0 _cmd  ��  e ��� l     ��������  ��  ��  � ��� i   1 4��� I      ������� 0 _check_icon  � ���� o      ���� 	0 _icon  ��  ��  � k     �� ��� l      ������  � � � Check if `_icon` exists, and if not revert to system download icon.

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
�� .ascrerr ****      � ****��  ��  � L    �� m    �� ��� � / S y s t e m / L i b r a r y / C o r e S e r v i c e s / C o r e T y p e s . b u n d l e / C o n t e n t s / R e s o u r c e s / S i d e b a r D o w n l o a d s F o l d e r . i c n s��  � ��� l     ��������  ��  ��  � ��� i   5 8��� I      ������� 0 
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
strq� o    ���� 0 _folder  ��  ��  ��  ��  ��  � ���� L    �� o    ���� 0 _folder  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� i   9 <��� I      ������� 0 _folder_exists  � ���� o      ���� 0 _folder  ��  ��  � k     �� ��� l      ������  � � � Return ``true`` if `_folder` exists, else ``false``

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
pcls� l   ������ 4    �� 
�� 
ditm  o    ���� 0 _folder  ��  ��  � m    ��
�� 
cfol��  ��  � m   	 
�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��  � �� L     m    ��
�� boovfals��  �  l     ��������  ��  ��    i   = @	 I      ��
���� 0 _path_exists  
 �� o      ���� 	0 _path  ��  ��  	 k     Y  l      ����   � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	  Z    ���� G      =     o     ���� 	0 _path   m    ��
�� 
msng n    I    ������ 0 	_is_empty   �� o    ���� 	0 _path  ��  ��    f     L     m    �
� boovfals��  ��   �~ Q    Y !"  k    O## $%$ Z   )&'�}�|& =    ()( n    *+* m    �{
�{ 
pcls+ o    �z�z 	0 _path  ) m    �y
�y 
alis' L   # %,, m   # $�x
�x boovtrue�}  �|  % -�w- Z   * O./01. E   * -232 o   * +�v�v 	0 _path  3 m   + ,44 �55  :/ k   0 866 787 4   0 5�u9
�u 
alis9 o   2 3�t�t 	0 _path  8 :�s: L   6 8;; m   6 7�r
�r boovtrue�s  0 <=< E   ; >>?> o   ; <�q�q 	0 _path  ? m   < =@@ �AA  /= B�pB k   A JCC DED c   A GFGF 4   A E�oH
�o 
psxfH o   C D�n�n 	0 _path  G m   E F�m
�m 
alisE I�lI L   H JJJ m   H I�k
�k boovtrue�l  �p  1 L   M OKK m   M N�j
�j boovfals�w  ! R      �iL�h
�i .ascrerr ****      � ****L o      �g�g 0 msg  �h  " L   W YMM m   W X�f
�f boovfals�~   NON l     �e�d�c�e  �d  �c  O PQP i   A DRSR I      �bT�a�b 0 	_is_empty  T U�`U o      �_�_ 0 _obj  �`  �a  S k     (VV WXW l      �^YZ�^  Y � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:returns: ``Boolean``
		
	   Z �[[   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
 	X \]\ l     �]^_�]  ^ ! # Is `_obj ` a ``Boolean``?   _ �`` 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?] aba Z    cd�\�[c E     efe J     gg hih m     �Z
�Z boovtruei j�Yj m    �X
�X boovfals�Y  f o    �W�W 0 _obj  d L   	 kk m   	 
�V
�V boovfals�\  �[  b lml l   �Uno�U  n ' !# Is `_obj ` a ``missing value``?   o �pp B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?m qrq Z   st�T�Ss =   uvu o    �R�R 0 _obj  v m    �Q
�Q 
msngt L    ww m    �P
�P boovtrue�T  �S  r xyx l   �Oz{�O  z " # Is `_obj ` a empty string?   { �|| 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?y }�N} L    (~~ =   '� n    %��� 1   # %�M
�M 
leng� l   #��L�K� n   #��� I    #�J��I�J 	0 _trim  � ��H� o    �G�G 0 _obj  �H  �I  �  f    �L  �K  � m   % &�F�F  �N  Q ��� l     �E�D�C�E  �D  �C  � ��B� i   E H��� I      �A��@�A 	0 _trim  � ��?� o      �>�> 0 _str  �?  �@  � k     ��� ��� l      �=���=  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string

	   � ���   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 
 	� ��� Z     ���<�;� G     ��� G     ��� >    ��� n     ��� m    �:
�: 
pcls� o     �9�9 0 _str  � m    �8
�8 
ctxt� >   ��� n    ��� m   	 �7
�7 
pcls� o    	�6�6 0 _str  � m    �5
�5 
TEXT� =   ��� o    �4�4 0 _str  � m    �3
�3 
msng� L    �� o    �2�2 0 _str  �<  �;  � ��� Z  ! -���1�0� =  ! $��� o   ! "�/�/ 0 _str  � m   " #�� ���  � L   ' )�� o   ' (�.�. 0 _str  �1  �0  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D�-��
�- 
cobj� m   > @�,�, � m   A C�+�+��� o   9 :�*�* 0 _str  � m   D E�)
�) 
ctxt� o      �(�( 0 _str  � R      �'��&
�' .ascrerr ****      � ****� o      �%�% 0 msg  �&  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�$�$ 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n�#��
�# 
cobj� m   h j�"�" � m   k m�!�!��� o   c d� �  0 _str  � m   n o�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****�  �  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�� 0 _str  � m   ] ^�� ���   � ��� L   � ��� o   � ��� 0 _str  �  �B       �� ���������������  � �������������
�	�� "0 bundler_version BUNDLER_VERSION� 	0 _home  � 0 bundler_dir BUNDLER_DIR� 0 	cache_dir 	CACHE_DIR� 0 load_bundler  � 0 
_bootstrap  � 0 _install_confirmation  � 0 _pwd  � 0 _prepare_cmd  � 0 _check_icon  � 0 
_check_dir  � 0 _folder_exists  �
 0 _path_exists  �	 0 	_is_empty  � 	0 _trim  � ��� " / U s e r s / s m a r g h e i m /� ��� � / U s e r s / s m a r g h e i m / L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - d e v e l� ��� � / U s e r s / s m a r g h e i m / L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - d e v e l� � F������ 0 load_bundler  �  �  � �� 0 
as_bundler  � �� i�  v��� 0 _folder_exists  � 0 
_bootstrap  
�  .sysodelanull��� ��� nmbr
�� .sysoloadscpt        file� 0)b  k+  e 
)j+ Y hO�j Ob  �%E�O�j � �� ����������� 0 
_bootstrap  ��  ��  � �������������� 0 urls URLs�� 0 _zipfile  �� 0 _url  �� 0 _status  �� 0 _cmd  �� 0 
as_bundler  �  ������ � � � ��� ������� � � ��� � ������� %9��@��P�������� 0 _install_confirmation  ��  ��  
�� 
strq
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� .sysoexecTEXT���     TEXT
�� 
errn�� �� 0 
_check_dir  �� 0 _path_exists  
�� .sysodelanull��� ��� nmbr
�� 
psxf
�� 
alis
�� .coredeloobj        obj �� � 
)j+  W 	X  fO�b   %�%�b   %�%lvE�Ob  �,�%E�O 1�[��l kh �%�%�%�%j E�O�a   Y h[OY��O�a  )a a la Y hO)b  k+ Oa b  �,%a %b  �,%E�O�j Ob  a %E�O h)�k+ a j [OY��Oa  *a b  /a &j UOh� ��\���������� 0 _install_confirmation  ��  ��  � �������������� 
0 _plist  �� 0 _cmd  �� 	0 _name  �� 	0 _icon  �� 	0 _text  �� 0 	_response  � ��p���������������������������������������	�� 0 _pwd  
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
errn�� �� �)j+  �%E�O�%�%E�O�j E�O)j+  �%E�O)�k+ E�O��%�%�%E�O�����mv�m��%a *a �/a  a ,E�O�a   eY hO�a    a  	a j UO)a a la Y hO�a   )a a la Y h� ������������ 0 _pwd  ��  ��  � ������ 0 astid ASTID�� 	0 _path  � 
����4������������S
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�� ��g���������� 0 _prepare_cmd  �� ����� �  ���� 0 _cmd  ��  � �������� 0 _cmd  �� 0 pwd  �� 0 testing_var  � ��������� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�%� ������������� 0 _check_icon  �� ����� �  ���� 	0 _icon  ��  � ���� 	0 _icon  � ���������
�� 
psxf
�� 
alis��  ��  ��  *�/�&O�W 	X  �� ������� ���� 0 
_check_dir  �� ����   ���� 0 _folder  ��    ���� 0 _folder   ��������� 0 _folder_exists  
�� 
strq
�� .sysoexecTEXT���     TEXT�� )�k+   ��,%j Y hO�� ����������� 0 _folder_exists  �� ����   ���� 0 _folder  ��   ���� 0 _folder   ���������� 0 _path_exists  
�� 
ditm
�� 
pcls
�� 
cfol�� )�k+   � *�/�,� UY hOf� ��	�������� 0 _path_exists  �� ����   ���� 	0 _path  ��   ������ 	0 _path  �� 0 msg   
����������4@������
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
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f� ��S����	
���� 0 	_is_empty  �� ��   �~�~ 0 _obj  ��  	 �}�} 0 _obj  
 �|�{�z
�| 
msng�{ 	0 _trim  
�z 
leng�� )eflv� fY hO��  eY hO)�k+ �,j � �y��x�w�v�y 	0 _trim  �x �u�u   �t�t 0 _str  �w   �s�r�s 0 _str  �r 0 msg   �q�p�o�n�m���l�k�j���i�h�
�q 
pcls
�p 
ctxt
�o 
TEXT
�n 
bool
�m 
msng
�l 
cobj�k 0 msg  �j  �i���h  �v ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O�ascr  ��ޭ