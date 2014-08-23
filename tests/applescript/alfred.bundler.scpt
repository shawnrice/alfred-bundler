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
ctxt��  ��  ��         l     �� ! "��   ! / )# Path to Alfred-Bundler's root directory    " � # # R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y    $ % $ j    �� &�� 0 bundler_dir BUNDLER_DIR & b     ' ( ' b     ) * ) l    +���� + o    ���� 	0 _home  ��  ��   * m     , , � - - � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - ( o    ���� "0 bundler_version BUNDLER_VERSION %  . / . l     ��������  ��  ��   /  0 1 0 l      �� 2 3��   2   MAIN API FUNCTION     3 � 4 4 &   M A I N   A P I   F U N C T I O N   1  5 6 5 l     ��������  ��  ��   6  7 8 7 i     9 : 9 I      �������� 0 load_bundler  ��  ��   : k     ) ; ;  < = < l      �� > ?��   > � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).
	
	:returns: ``script object``
	
	    ? � @ @�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 	 
 	 : r e t u r n s :   ` ` s c r i p t   o b j e c t ` ` 
 	 
 	 =  A B A l     �� C D��   C , &# Check if Alfred-Bundler is installed    D � E E L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d B  F G F Z      H I���� H >     J K J l    
 L���� L n    
 M N M I    
�� O���� 0 _folder_exists   O  P�� P o    ���� 0 bundler_dir BUNDLER_DIR��  ��   N  f     ��  ��   K m   
 ��
�� boovtrue I k     Q Q  R S R l   �� T U��   T  # install it if not    U � V V & #   i n s t a l l   i t   i f   n o t S  W�� W n    X Y X I    �������� 0 
_bootstrap  ��  ��   Y  f    ��  ��  ��   G  Z [ Z l   �� \ ]��   \ ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    ] � ^ ^ r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y [  _ ` _ r    " a b a l     c���� c b      d e d o    ���� 0 bundler_dir BUNDLER_DIR e m     f f � g g 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��   b o      ���� 0 
as_bundler   `  h i h l  # #�� j k��   j  # Return script object    k � l l , #   R e t u r n   s c r i p t   o b j e c t i  m�� m L   # ) n n I  # (�� o��
�� .sysoloadscpt        file o o   # $���� 0 
as_bundler  ��  ��   8  p q p l     ��������  ��  ��   q  r s r l      �� t u��   t   AUTO-DOWNLOAD BUNDLER     u � v v .   A U T O - D O W N L O A D   B U N D L E R   s  w x w l     ��������  ��  ��   x  y z y i     { | { I      �������� 0 
_bootstrap  ��  ��   | k     # } }  ~  ~ l      �� � ���   � j d Check if bundler bash bundlet is installed and install it if not.

    	:returns: ``None``
		
    	    � � � � �   C h e c k   i f   b u n d l e r   b a s h   b u n d l e t   i s   i n s t a l l e d   a n d   i n s t a l l   i t   i f   n o t . 
 
         	 : r e t u r n s :   ` ` N o n e ` ` 
 	 	 
         	   � � � r      � � � n     	 � � � 1    	��
�� 
strq � l     ����� � b      � � � l     ����� � n     � � � I    �������� 0 _pwd  ��  ��   �  f     ��  ��   � m     � � � � � " a l f r e d . b u n d l e r . s h��  ��   � o      ���� 0 shell_bundlet   �  � � � r     � � � b     � � � o    ���� 0 shell_bundlet   � m     � � � � � (   u t i l i t y   C o c o a D i a l o g � o      ���� 0 	shell_cmd   �  � � � r     � � � n    � � � I    �� ����� 0 _prepare_cmd   �  ��� � o    ���� 0 	shell_cmd  ��  ��   �  f     � o      ���� 0 cmd   �  � � � I    �� ���
�� .sysoexecTEXT���     TEXT � o    ���� 0 cmd  ��   �  ��� � L   ! # � � m   ! "��
�� boovtrue��   z  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   HELPER HANDLERS     � � � � "   H E L P E R   H A N D L E R S   �  � � � l     ��������  ��  ��   �  � � � i    ! � � � I      �������� 0 _pwd  ��  ��   � k     8 � �  � � � l      �� � ���   � � ~ Get path to "present working directory", i.e. the workflow's root directory.

    	:returns: ``string`` (POSIX path)
		
    	    � � � � �   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 
         	 : r e t u r n s :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 	 
         	 �  � � � l     �� � ���   � = 7# Save default AS delimiters, and set delimiters to "/"    � � � � n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / " �  � � � r      � � � J      � �  � � � n     � � � 1    ��
�� 
txdl � 1     ��
�� 
ascr �  ��� � m     � � � � �  /��   � J       � �  � � � o      ���� 0 astid ASTID �  ��� � n      � � � 1    ��
�� 
txdl � 1    ��
�� 
ascr��   �  � � � l   �� � ���   � , &# Get POSIX path of script's directory    � � � � L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r y �  � � � r    / � � � b    - � � � l   + ����� � c    + � � � n    ) � � � 7   )�� � �
�� 
citm � m   # %����  � m   & (������ � l    ����� � n     � � � 1    ��
�� 
psxp � l    ����� � I   �� ���
�� .earsffdralis        afdr �  f    ��  ��  ��  ��  ��   � m   ) *��
�� 
TEXT��  ��   � m   + , � � � � �  / � o      ���� 	0 _path   �  � � � l  0 0�� � ���   � . (# Reset AS delimiters to original values    � � � � P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e s �  � � � r   0 5 � � � o   0 1���� 0 astid ASTID � n      � � � 1   2 4��
�� 
txdl � 1   1 2��
�� 
ascr �  ��� � L   6 8 � � o   6 7���� 	0 _path  ��   �  � � � l     �������  ��  �   �  � � � i   " % � � � I      �~ ��}�~ 0 _prepare_cmd   �  ��| � o      �{�{ 0 _cmd  �|  �}   � k      � �  �  � l      �z�z  ;5 Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.
	
	:param _cmd: Shell command to be run in `do shell script`
    	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
    	:returns: ``string``
		
    	    �j   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r t y   d i r e c t o r y . 
 	 F o r   t e s t i n g   p u r p o s e s ,   i t   a l s o   s e t s   t h e   ` A B _ B R A N C H `   e n v i r o n m e n t a l   v a r i a b l e . 
 	 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
         	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
         	 : r e t u r n s :   ` ` s t r i n g ` ` 
 	 	 
         	   l     �y�y   9 3# Ensure `pwd` is properly quoted for shell command    � f #   E n s u r e   ` p w d `   i s   p r o p e r l y   q u o t e d   f o r   s h e l l   c o m m a n d 	
	 r     	 n      1    �x
�x 
strq l    �w�v n     I    �u�t�s�u 0 _pwd  �t  �s    f     �w  �v   o      �r�r 0 pwd  
  l  
 
�q�q   &  # Declare environmental variable    � @ #   D e c l a r e   e n v i r o n m e n t a l   v a r i a b l e  l  
 
�p�p   % #TODO: remove for final release    � > # T O D O :   r e m o v e   f o r   f i n a l   r e l e a s e  r   
  m   
    �!! 0 e x p o r t   A B _ B R A N C H = d e v e l ;   o      �o�o 0 testing_var   "#" l   �n$%�n  $ 7 1# return shell script where `pwd` is properly set   % �&& b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t# '�m' L    (( b    )*) b    +,+ b    -.- b    /0/ o    �l�l 0 testing_var  0 m    11 �22  c d  . o    �k�k 0 pwd  , m    33 �44  ;   b a s h  * o    �j�j 0 _cmd  �m   � 565 l     �i�h�g�i  �h  �g  6 787 i   & )9:9 I      �f;�e�f 0 _folder_exists  ; <�d< o      �c�c 0 _folder  �d  �e  : k     == >?> l      �b@A�b  @ � � Return ``true`` if `_folder` exists, else ``false``
	
	:param _folder: Full path to directory
    	:type _folder: ``string`` (POSIX path)
    	:returns: ``Boolean``
		
    	   A �BB\   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 	 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
         	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
         	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
         	? CDC Z     EF�a�`E n    GHG I    �_I�^�_ 0 _path_exists  I J�]J o    �\�\ 0 _folder  �]  �^  H  f     F O   	 KLK L    MM l   N�[�ZN =   OPO n    QRQ m    �Y
�Y 
pclsR l   S�X�WS 4    �VT
�V 
ditmT o    �U�U 0 _folder  �X  �W  P m    �T
�T 
cfol�[  �Z  L m   	 
UU�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �a  �`  D V�SV L    WW m    �R
�R boovfals�S  8 XYX l     �Q�P�O�Q  �P  �O  Y Z[Z i   * -\]\ I      �N^�M�N 0 _path_exists  ^ _�L_ o      �K�K 	0 _path  �L  �M  ] k     Y`` aba l      �Jcd�J  c � � Return ``true`` if `_path` exists, else ``false``
	
	:param _path: Any POSIX path (file or folder)
    	:type _path: ``string`` (POSIX path)
    	:returns: ``Boolean``
		
    	   d �eeb   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 	 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
         	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
         	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
         	b fgf Z    hi�I�Hh G     jkj =    lml o     �G�G 	0 _path  m m    �F
�F 
msngk n   non I    �Ep�D�E 0 	_is_empty  p q�Cq o    �B�B 	0 _path  �C  �D  o  f    i L    rr m    �A
�A boovfals�I  �H  g s�@s Q    Ytuvt k    Oww xyx Z   )z{�?�>z =    |}| n    ~~ m    �=
�= 
pcls o    �<�< 	0 _path  } m    �;
�; 
alis{ L   # %�� m   # $�:
�: boovtrue�?  �>  y ��9� Z   * O����� E   * -��� o   * +�8�8 	0 _path  � m   + ,�� ���  :� k   0 8�� ��� 4   0 5�7�
�7 
alis� o   2 3�6�6 	0 _path  � ��5� L   6 8�� m   6 7�4
�4 boovtrue�5  � ��� E   ; >��� o   ; <�3�3 	0 _path  � m   < =�� ���  /� ��2� k   A J�� ��� c   A G��� 4   A E�1�
�1 
psxf� o   C D�0�0 	0 _path  � m   E F�/
�/ 
alis� ��.� L   H J�� m   H I�-
�- boovtrue�.  �2  � L   M O�� m   M N�,
�, boovfals�9  u R      �+��*
�+ .ascrerr ****      � ****� o      �)�) 0 msg  �*  v L   W Y�� m   W X�(
�( boovfals�@  [ ��� l     �'�&�%�'  �&  �%  � ��� i   . 1��� I      �$��#�$ 0 	_is_empty  � ��"� o      �!�! 0 _obj  �"  �#  � k     (�� ��� l      � ���   � � � Return ``true`` if `_obj ` is empty, else ``false``
	
	:param _obj: Any Applescript type
    	:type _obj: (optional)
    	:returns: ``Boolean``
		
    	   � ���2   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 	 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
         	 : t y p e   _ o b j :   ( o p t i o n a l ) 
         	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
         	� ��� l     ����  � ! # Is `_obj ` a ``Boolean``?   � ��� 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?� ��� Z    ����� E     ��� J     �� ��� m     �
� boovtrue� ��� m    �
� boovfals�  � o    �� 0 _obj  � L   	 �� m   	 
�
� boovfals�  �  � ��� l   ����  � ' !# Is `_obj ` a ``missing value``?   � ��� B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?� ��� Z   ����� =   ��� o    �� 0 _obj  � m    �
� 
msng� L    �� m    �
� boovtrue�  �  � ��� l   ����  � " # Is `_obj ` a empty string?   � ��� 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?� ��� L    (�� =   '��� n    %��� 1   # %�
� 
leng� l   #���� n   #��� I    #���� 	0 _trim  � ��
� o    �	�	 0 _obj  �
  �  �  f    �  �  � m   % &��  �  � ��� l     ����  �  �  � ��� i   2 5��� I      ���� 	0 _trim  � ��� o      � �  0 _str  �  �  � k     ��� ��� l      ������  � � � Remove white space from beginning and end of `_str`
	
	:param _str: A text string
    	:type _str: ``string``
    	:returns: trimmed string
		
    	   � ���*   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 	 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
         	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
         	 : r e t u r n s :   t r i m m e d   s t r i n g 
 	 	 
         	� ��� Z     ������� G     ��� G     ��� >    ��� n     ��� m    ��
�� 
pcls� o     ���� 0 _str  � m    ��
�� 
ctxt� >   ��� n    ��� m   	 ��
�� 
pcls� o    	���� 0 _str  � m    ��
�� 
TEXT� =   ��� o    ���� 0 _str  � m    ��
�� 
msng� L    �� o    ���� 0 _str  ��  ��  � ��� Z  ! -������� =  ! $   o   ! "���� 0 _str   m   " # �  � L   ' ) o   ' (���� 0 _str  ��  ��  �  V   . W Q   6 R	
	 r   9 H c   9 F n   9 D 7  : D��
�� 
cobj m   > @����  m   A C������ o   9 :���� 0 _str   m   D E��
�� 
ctxt o      ���� 0 _str  
 R      ����
�� .ascrerr ****      � **** o      ���� 0 msg  ��   L   P R m   P Q �   C  2 5 o   2 3���� 0 _str   m   3 4 �     V   X � Q   ` | !"  r   c r#$# c   c p%&% n   c n'(' 7  d n��)*
�� 
cobj) m   h j���� * m   k m������( o   c d���� 0 _str  & m   n o��
�� 
ctxt$ o      ���� 0 _str  ! R      ������
�� .ascrerr ****      � ****��  ��  " L   z |++ m   z {,, �--   D   \ _./. o   \ ]���� 0 _str  / m   ] ^00 �11    2��2 L   � �33 o   � ����� 0 _str  ��  �       ��4 56789:;<=>��  4 ������������������������ "0 bundler_version BUNDLER_VERSION�� 	0 _home  �� 0 bundler_dir BUNDLER_DIR�� 0 load_bundler  �� 0 
_bootstrap  �� 0 _pwd  �� 0 _prepare_cmd  �� 0 _folder_exists  �� 0 _path_exists  �� 0 	_is_empty  �� 	0 _trim  5 �?? " / U s e r s / s m a r g h e i m /6 �@@ � / U s e r s / s m a r g h e i m / L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - d e v e l7 �� :����AB���� 0 load_bundler  ��  ��  A ���� 0 
as_bundler  B ���� f���� 0 _folder_exists  �� 0 
_bootstrap  
�� .sysoloadscpt        file�� *)b  k+  e 
)j+ Y hOb  �%E�O�j 8 �� |����CD���� 0 
_bootstrap  ��  ��  C �������� 0 shell_bundlet  �� 0 	shell_cmd  �� 0 cmd  D �� ��� ������� 0 _pwd  
�� 
strq�� 0 _prepare_cmd  
�� .sysoexecTEXT���     TEXT�� $)j+  �%�,E�O��%E�O)�k+ E�O�j Oe9 �� �����EF���� 0 _pwd  ��  ��  E ������ 0 astid ASTID�� 	0 _path  F 
���� ������������� �
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�: �� �����GH���� 0 _prepare_cmd  �� ��I�� I  ���� 0 _cmd  ��  G �������� 0 _cmd  �� 0 pwd  �� 0 testing_var  H ���� 13�� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�%; ��:����JK���� 0 _folder_exists  �� ��L�� L  ���� 0 _folder  ��  J ���� 0 _folder  K ��U�������� 0 _path_exists  
�� 
ditm
�� 
pcls
�� 
cfol�� )�k+   � *�/�,� UY hOf< ��]����MN���� 0 _path_exists  �� ��O�� O  ���� 	0 _path  ��  M ������ 	0 _path  �� 0 msg  N 
������������������
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
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f= �������PQ���� 0 	_is_empty  �� ��R�� R  ���� 0 _obj  ��  P ���� 0 _obj  Q ��~�}
� 
msng�~ 	0 _trim  
�} 
leng�� )eflv� fY hO��  eY hO)�k+ �,j > �|��{�zST�y�| 	0 _trim  �{ �xU�x U  �w�w 0 _str  �z  S �v�u�v 0 _str  �u 0 msg  T �t�s�r�q�p�o�n�m0�l�k,
�t 
pcls
�s 
ctxt
�r 
TEXT
�q 
bool
�p 
msng
�o 
cobj�n 0 msg  �m  �l���k  �y ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O� ascr  ��ޭ