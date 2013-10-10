--                              -*- Mode: Ada -*-
--  Filename        : sdl-video-pixel_formats.ads
--  Description     : Description of various pixel formats.
--  Author          : Luke A. Guest
--  Created On      : Tue Sep 24 19:57:32 2013
with Ada.Characters.Latin_1;
with Ada.Unchecked_Conversion;
with Interfaces;
with Interfaces.C;
with SDL.Video.Palettes;

package SDL.Video.Pixel_Formats is
   package C renames Interfaces.C;

   type Pixel_Types is
     (Unknown,
      Index_1,
      Index_4,
      Index_8,
      Packed_8,
      Packed_16,
      Packed_32,
      Array_U8,
      Array_U16,
      Array_U32,
      Array_F16,
      Array_F32) with
     Convention => C;

   --  Bitmap pixel order, high bit -> low bit.
   type Bitmap_Pixel_Order is (None, Little_Endian, Big_Endian) with
     Convention => C;

   --  Packed component order, high bit -> low bit.
   type Packed_Component_Order is
     (None,
      XRGB,
      RGBX,
      ARGB,
      RGBA,
      XBGR,
      BGRX,
      ABGR,
      BGRA) with
     Convention => C;

   --  Array component order, low byte -> high byte.
   type Array_Component_Order is (None, RGB, RGBA, ARGB, BGR, BGRA, ABGR);

   --  Describe how the components are laid out in bit form.
   type Packed_Component_Layout is
     (None,
      Bits_332,
      Bits_4444,
      Bits_1555,
      Bits_5551,
      Bits_565,
      Bits_8888,
      Bits_2101010,
      Bits_1010102) with
     Convention => C;

   type Bits_Per_Pixels is range 0 .. 32 with
     Static_Predicate => Bits_Per_Pixels in 0 | 1 | 4 | 8 | 12 | 15 | 16 | 24 | 32,
     Convention       => C;

   Bits_Per_Pixel_Error : constant Bits_Per_Pixels := 0;

   type Bytes_Per_Pixels is range 0 .. 4 with
     Convention => C;

   Bytes_Per_Pixel_Error : constant Bytes_Per_Pixels := Bytes_Per_Pixels'First;

   --   29 28   24   20   16        8        0
   --  000 1  tttt oooo llll bibibibi bybybyby
   --
   --  or
   --
   --        24       16        8        0
   --  DDDDDDDD CCCCCCCC BBBBBBBB AAAAAAAA
   type Pixel_Orders (Pixel_Type : Pixel_Types := Unknown) is
      record
         case Pixel_Type is
            when Index_1 | Index_4 | Index_8 =>
               Indexed_Order : Bitmap_Pixel_Order;

            when Packed_8 | Packed_16 | Packed_32 =>
               Packed_Order  : Packed_Component_Order;

            when Array_U8 | Array_U16 | Array_U32 | Array_F16 | Array_F32 =>
               Array_Order   : Array_Component_Order;

            when others =>
               null;
         end case;
      end record with
        Unchecked_Union => True,
        Convention      => C,
        Size            => 4;

   for Pixel_Orders use
      record
         Indexed_Order at 0 range 0 .. 2;
         Packed_Order  at 0 range 0 .. 3;
         Array_Order   at 0 range 0 .. 3;
      end record;

   type Planar_Pixels is
      record
         A : Character;
         B : Character;
         C : Character;
         D : Character;
      end record with
        Size            => 32,
        Convention      => C;

   for Planar_Pixels use
      record
         A at 0 range  0 ..  7;
         B at 0 range  8 .. 15;
         C at 0 range 16 .. 23;
         D at 0 range 24 .. 31;
      end record;

   type Non_Planar_Pixel_Padding is range 0 .. 7 with
     Convention => C;

   type Non_Planar_Pixels is
      record
         Bytes_Per_Pixel : Bytes_Per_Pixels;
         Bits_Per_Pixel  : Bits_Per_Pixels;
         Layout          : Packed_Component_Layout;
         Pixel_Order     : Pixel_Orders;
         Pixel_Type      : Pixel_Types;
         Flag            : Boolean;
         Padding         : Non_Planar_Pixel_Padding;
      end record with
        Size            => 32,
        Convention      => C;

   for Non_Planar_Pixels use
      record
         Bytes_Per_Pixel at 0 range  0 ..  7;
         Bits_Per_Pixel  at 0 range  8 .. 15;
         Layout          at 0 range 16 .. 19;
         Pixel_Order     at 0 range 20 .. 23;
         Pixel_Type      at 0 range 24 .. 27;
         Flag            at 0 range 28 .. 28;
         Padding         at 0 range 29 .. 31;
      end record;

   type Pixel_Format_Names (Planar : Boolean := False) is
      record
         case Planar is
            when True =>
               Planar_Format     : Planar_Pixels;
            when False =>
               Non_Planar_Format : Non_Planar_Pixels;
         end case;
      end record with
        Unchecked_Union => True,
        Size            => 32,
        Convention      => C;

   Pixel_Format_Unknown     : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => True,
                         Planar_Format => Planar_Pixels'
                           (others => Ada.Characters.Latin_1.nul));

   Pixel_Format_Index_1_LSB : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Index_1,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type    => Index_1,
                               Indexed_Order => Little_Endian),
                            Layout          => None,
                            Bits_Per_Pixel  => 1,
                            Bytes_Per_Pixel => 0));

   Pixel_Format_Index_1_MSB : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Index_1,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type    => Index_1,
                               Indexed_Order => Big_Endian),
                            Layout          => None,
                            Bits_Per_Pixel  => 1,
                            Bytes_Per_Pixel => 0));

   Pixel_Format_Index_4_LSB : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Index_1,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type    => Index_1,
                               Indexed_Order => Little_Endian),
                            Layout          => None,
                            Bits_Per_Pixel  => 4,
                            Bytes_Per_Pixel => 0));

   Pixel_Format_Index_4_MSB : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Index_1,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type    => Index_1,
                               Indexed_Order => Big_Endian),
                            Layout          => None,
                            Bits_Per_Pixel  => 4,
                            Bytes_Per_Pixel => 0));

   Pixel_Format_Index_8 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Index_8,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type    => Index_8,
                               Indexed_Order => None),
                            Layout          => None,
                            Bits_Per_Pixel  => 8,
                            Bytes_Per_Pixel => 1));

   Pixel_Format_RGB332 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_8,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_8,
                               Packed_Order => XRGB),
                            Layout          => Bits_332,
                            Bits_Per_Pixel  => 8,
                            Bytes_Per_Pixel => 1));

   Pixel_Format_RGB444 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => XRGB),
                            Layout          => Bits_4444,
                            Bits_Per_Pixel  => 12,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_RGB555 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => XRGB),
                            Layout          => Bits_1555,
                            Bits_Per_Pixel  => 15,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_BGR555 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => XBGR),
                            Layout          => Bits_1555,
                            Bits_Per_Pixel  => 15,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_ARGB4444 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => ARGB),
                            Layout          => Bits_4444,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_RGBA4444 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => RGBA),
                            Layout          => Bits_4444,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_ABGR4444 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => ABGR),
                            Layout          => Bits_4444,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_BGRA4444 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => BGRA),
                            Layout          => Bits_4444,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_ARGB1555 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => ARGB),
                            Layout          => Bits_1555,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_RGBA1555 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => RGBA),
                            Layout          => Bits_1555,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_ABGR1555 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => ABGR),
                            Layout          => Bits_1555,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_BGRA5551 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => BGRA),
                            Layout          => Bits_5551,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_RGB565 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => XRGB),
                            Layout          => Bits_565,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_BGR565 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_16,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_16,
                               Packed_Order => XBGR),
                            Layout          => Bits_565,
                            Bits_Per_Pixel  => 16,
                            Bytes_Per_Pixel => 2));

   Pixel_Format_RGB24 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Array_U8,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type  => Array_U8,
                               Array_Order => RGB),
                            Layout          => None,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 3));

   Pixel_Format_BGR24 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Array_U8,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type  => Array_U8,
                               Array_Order => BGR),
                            Layout          => None,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 3));

   Pixel_Format_RGB888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => XRGB),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_RGBX8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => RGBX),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_BGR888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => XBGR),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_BGRX8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => BGRX),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 24,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_ARGB8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => ARGB),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 32,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_RGBA8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => RGBA),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 32,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_ABGR8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => ABGR),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 32,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_BGRA8888 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => BGRA),
                            Layout          => Bits_8888,
                            Bits_Per_Pixel  => 32,
                            Bytes_Per_Pixel => 4));

   Pixel_Format_ARGB2101010 : Pixel_Format_Names :=
     Pixel_Format_Names'(Planar => False,
                         Non_Planar_Format => Non_Planar_Pixels'
                           (Padding         => 0,
                            Flag            => True,
                            Pixel_Type      => Packed_32,
                            Pixel_Order     => Pixel_Orders'
                              (Pixel_Type   => Packed_32,
                               Packed_Order => ARGB),
                            Layout          => Bits_2101010,
                            Bits_Per_Pixel  => 32,
                            Bytes_Per_Pixel => 4));

   type Colour_Mask is mod 2 ** 32 with
     Convention => C;

   type Private_Pixel_Format is private;

   type Pixel_Format is
      record
         Format       : Pixel_Format_Names;
         Palette      : Palettes.Internal_Palette_Access;
         Bits         : Bits_Per_Pixels;
         Bytes        : Bytes_Per_Pixels;
         Padding      : Interfaces.Unsigned_16;
         Red_Mask     : Colour_Mask;
         Green_Mask   : Colour_Mask;
         Blue_Mask    : Colour_Mask;
         Alpha_Mask   : Colour_Mask;

         --  This is mainly padding to make sure the record size matches what is expected from C.
         Private_Part : Private_Pixel_Format;
      end record with
        Convention => C;

   type Pixel_Format_Access is access all Pixel_Format with
     Convention => C;

   function Create (Format : in Pixel_Format_Names) return Pixel_Format_Access with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AllocFormat";

   procedure Free (Format : in Pixel_Format_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FreeFormat";

   function Image (Format : in Pixel_Format_Names) return String;
     --  Import        => True,
     --  Convention    => C,
     --  External_Name => "SDL_GetPixelFormatName";

   procedure To_Components
     (Pixel  : in  Interfaces.Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out Palettes.Colour_Component;
      Green  : out Palettes.Colour_Component;
      Blue   : out Palettes.Colour_Component) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGB";

   procedure To_Components
     (Pixel  : in  Interfaces.Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out Palettes.Colour_Component;
      Green  : out Palettes.Colour_Component;
      Blue   : out Palettes.Colour_Component;
      Alpha  : out Palettes.Colour_Component) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGBA";

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in Palettes.Colour_Component;
      Green  : in Palettes.Colour_Component;
      Blue   : in Palettes.Colour_Component) return Interfaces.Unsigned_32 with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGB";

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in Palettes.Colour_Component;
      Green  : in Palettes.Colour_Component;
      Blue   : in Palettes.Colour_Component;
      Alpha  : in Palettes.Colour_Component) return Interfaces.Unsigned_32 with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGBA";

   function To_Name
     (Bits       : in Bits_Per_Pixels;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Names with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MasksToPixelFormatEnum";

   function To_Masks
     (Format     : in  Pixel_Format_Names;
      Bits       : out Bits_Per_Pixels;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return Boolean with
     Inline => True;

   --  Gamma
   type Gamma_Value is mod 2 ** 16 with
     Convention => C;

   type Gamma_Ramp is array (Integer range 1 .. 256) of Gamma_Value with
     Convention => C;

   procedure Calculate (Gamma : in Float; Ramp : out Gamma_Ramp) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CalculateGammaRamp";
private
   --  SDL_Ada_Pixel_Format_Unknown : constant Interfaces.Unsigned_32 with
   --    Import        => True,
   --    Convention    => C,
   --    External_Name => "SDL_Ada_Pixel_Format_Unknown";

--   for Pixel_Format_Names use (Unknown => SDL_Ada_Pixel_Format_Unknown);

   --  The following fields are defined as "internal use" in the SDL docs.
   type Private_Pixel_Format is
      record
         Rred_Loss   : Interfaces.Unsigned_8;
         Green_Loss  : Interfaces.Unsigned_8;
         Blue_Loss   : Interfaces.Unsigned_8;
         Alpha_Loss  : Interfaces.Unsigned_8;
         Red_Shift   : Interfaces.Unsigned_8;
         Green_Shift : Interfaces.Unsigned_8;
         Blue_Shift  : Interfaces.Unsigned_8;
         Alpha_Shift : Interfaces.Unsigned_8;
         Ref_Count   : C.int;
         Next        : Pixel_Format_Access;
      end record with
        Convention => C;
end SDL.Video.Pixel_Formats;
