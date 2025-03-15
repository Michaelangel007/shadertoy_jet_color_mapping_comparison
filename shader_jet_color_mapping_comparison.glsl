// If you want faster compile time disable FULL_STATUS (or even FONT)
    #define FULL_STATUS 1 // Enable descriptive status bar with algorithm names
    #define FONT        1 // Enable font
    #define DEBUG       0 // Show mouse position, texture resolution
// For screenshots disable
    #define METRONOME   1
    #define LABELS      1
    #define SEPARATOR   1

/*
=== Summary ===

(Super) Jet Color Mapping Comparison
https://www.shadertoy.com/view/tc2SDw
Copyleft {C} by Michael Pohoreski / Michaelangel007 / mysticreddit
March 14, 2025

Tags: jet, viridus, parula, plasma, magma, inferno, turbo, hot2cold, rainbow, colormap, colorramp, falsecolor, spectrum, palette
Additional tags: spectrum, spectral, hue

* Original
* Black and White (Perceived Lightness)
* EvalDraw
* HotToCold
* Inferno
* Jet
* Magma
* Parula (CC0 version due to Mathworks being IP assholes about Parula)
* Plasma
* Sine Engima
* Sine Jet
* Viridus
* Turbo

=== Instructions ===

1. While holding down the left mouse button ...
   (The raw sRGB pre-gamma corrected image will be shown.)

2. ... move the mouse left/right to select the mode:

 * Left   1/3: photo mode
 * Middle 1/3: gradient mode
 * Right  1/3: RGB curves mode

3. ... move the mouse up/down to select the algorithm:

 A. Jet (popularized by MATLAB)
 B. Turbo (Google)
 C. Sine Jet (Michael Pohoreski)
 D. EvalDraw (Ken Silverman)
 E. Hot Cold
 F. Sine Enigma (Michael Pohoreski)
 G. Black & White (Perceived Lightness)
 H. Inferno
 I. Magma
 J. Plasma
 K. Parula (by wagyx and not MATHLAB's "propietary" color mapping. LUL.)
 L. Viridus (open-source replacement for Parula)
 M. Original image (Easter Egg)

The bars in gradient mode are:

1) Split into two:
   * HSV bar (narrow top strip), and
   * Color palette (wide bottom strip)
2) Red   channel of color palette
3) Green channel of color palette
4) Blue  channel of color palette
5) Split in two:
   * Percieved Lightness of the color palette (wide top strip), and
   * Linear brightness as  reference (narrow bottom strip)
6) Color "Sweep". 
   There is a metronome that sweeps through the color palette.
   It is displayed a solid color.

The RGB color curves shows the red, green, blue contributions for the palette.

=== Introduction ===

There are various ways to "false color" raw data. 

First, we normalize the data.

By normalizing we mean remap the:

* lowest value to 0.0 (inclusive), and
* highest value to 1.0 (inclusive).

Second, we display the normalized data. Should we use:

* a grayscale image?
* a color image?

Unfortunately gray MAY make it hard to see SMALL delta changes.

If we show colors instead of gray this process is called "color mapping."

We normally have a palette (of 256 entries) that we can
"map" the normalized gray scale value to the closest color entry.

Remapping this gray scale to Light's wavelengths (~400nm to ~700nm)
produces a "rainbow" output.

A naive approach would be to map gray to HSV where Saturation=1, Value=1.
   
=== Classic Jet Mapping ===

An (old) "de facto" standard in the scientic community was to false color
a grayscale image with a color mapping or palette called "Jet" or
"Rainbow" color mapping due to it looking like a rainbow.

It became popular due to MATLAB making it the default color map.

MATLAB defines several color maps:
* https://www.mathworks.com/help/matlab/ref/colormap.html

It is defined as a linear ramp between the following 9 colors:

   Stop  HexRGB   Color Float          Color Name
   0/8:  #00007F  vec3(0.0, 0.0, 0.5)  dark blue
   1/8:  #0000FF  vec3(0.0, 0.0, 1.0)  blue
   2/8:  #007FFF  vec3(0.0, 0.5, 1.0)  azure
   3/8:  #00FFFF  vec3(0.0, 1.0, 1.0)  cyan
   4/8:  #7FFF7F  vec3(0.5, 1.0, 0.5)  light green
   5/8:  #FFFF00  vec3(1.0, 1.0, 0.0)  yellow
   6/8:  #FF7F00  vec3(1.0, 0.5, 0.0)  orange
   7/8:  #FF0000  vec3(1.0, 0.0, 0.0)  red
   8/8:  #7F0000  vec3(0.5, 0.0, 0.0)  dark red

An naive algorithm that implements the Jet color remapping is:
*/

#if 0
    // Author: Michael Pohoreski
    // CC0 version
    vec3 Map_Jet_MATLAB( float t )
    {
        const vec3 K0 = vec3(0.0, 0.0, 0.5);
        const vec3 K1 = vec3(0.0, 0.0, 1.0);
        const vec3 K2 = vec3(0.0, 0.5, 1.0);
        const vec3 K3 = vec3(0.0, 1.0, 1.0);
        const vec3 K4 = vec3(0.5, 1.0, 0.5);
        const vec3 K5 = vec3(1.0, 1.0, 0.0);
        const vec3 K6 = vec3(1.0, 0.5, 0.0);
        const vec3 K7 = vec3(1.0, 0.0, 0.0);
        const vec3 K8 = vec3(0.5, 0.0, 0.0);
        const float w = 1./8.;
        /* */ vec3  c = vec3(0);
        
        /**/ if (t < 1./8.) { c = mix( K0, K1, 8.*(t - (0./8.) ); }
        else if (t < 2./8.) { c = mix( K1, K2, 8.*(t - (1./8.) ); }
        else if (t < 3./8.) { c = mix( K2, K3, 8.*(t - (2./8.) ); }
        else if (t < 4./8.) { c = mix( K3, K4, 8.*(t - (3./8.) ); }
        else if (t < 5./8.) { c = mix( K4, K5, 8.*(t - (4./8.) ); }
        else if (t < 6./8.) { c = mix( K5, K6, 8.*(t - (5./8.) ); }
        else if (t < 7./8.) { c = mix( K6, K7, 8.*(t - (6./8.) ); }
        else /*          */ { c = mix( K7, K8, 8.*(t - (7./8.) ); }
    
        return clamp( c, vec3(0), vec3(1) );
    }
#endif

/*
All those branches are HORRIBLE for performance on a GPU.
Joshua Fraser has a version that is native/performant in GLSL:

    // Author: Joshua Fraser
    // https://stackoverflow.com/a/46628410
    vec3 Map_Jet_JoshuaFraser( float t )
    {
        return clamp((vec3(1.5) - abs(4.0*vec3(t) + vec3(-3,-2,-1))), 0., 1.);
    }

I first came across Jet color mapping with Peter Bennett's blog ...

  "OpenGL Minecraft Style Volume Rendering"
  * http://bytebash.com/2012/03/opengl-volume-rendering/
  * https://web.archive.org/web/20130111133715/http://bytebash.com/2012/03/opengl-volume-rendering/

... where he implemented the Jet Mapping.

    "In addition to this, I also wrote a fragment shader in GLSL which
     colours each block in the volume based on its vertical position
     using the common jet colour mapping:"

    //VALUE in this case is the y position of the block and ranges from 0 to 255
    float k = 4*(VALUE/float(255));
    float red = clamp(min(k - 1.5, -k + 4.5),0.0,1.0);
    float green = clamp(min(k - 0.5, -k + 3.5),0.0,1.0);
    float blue  = clamp(min(k + 0.5, -k + 2.5),0.0,1.0);

We can clean that up to be a little more readable:

    // Author: Peter Bennett
    // Cleanup: Michael Pohoreski 
    vec3 Map_Jet_PeterBennett( float t )
    {
        float k = 4.0 * t;
        float r = min( k - 1.5, -k + 4.5);
        float g = min( k - 0.5, -k + 3.5);
        float b = min( k + 0.5, -k + 2.5);
        return clamp(vec3(r,g,b), 0.0, 1.0);
    }

=== Sine Jet Mapping === 

If look at the color curves for Jet we notice that they
crudely look like sine waves with a phase shift and then shifted up.

    vec3 Map_SineJet_MichaelPohoreski( float t )
    {
        float rad =              t  * M_TAU   ;
        float r = sin( rad + (2./4. * M_TAU) );
        float g = sin( rad + (3./4. * M_TAU) );
        float b = sin( rad + (0./4. * M_TAU) );
        return 0.5 + 0.5*vec3(r,g,b);
    }

=== Hot To Cold Mapping ===

If we "relax" the ends of the Jet color mapping so they are "held high":

 * Blue remains at 1.0 from t = [0.0   .. 0.125]
 * Red  remains at 1.0 from t = [0.875 .. 1.0  ]

We can simplify the equations. This is the "Hot To Cold" mapping.

Unfortunately this is naive since it causes loss of fidelity:

* under-exposure (lows)
* over-exposure (highs)

Regardless, the color curves looks this:
    
RGB:

      -0.5    +0.5
        |       |
        v       v
    BBBBBGGGGGGGRRRRR  1.00
    ...G.B.....R.G...  0.75
    ..G...R...R...G..  0.50
    .G.....B.R.....G.  0.25
    GRRRRRRRR.......G  0.00
    ^       ^       ^
    -1      0      +1

Red:

      -0.5    +0.5
        |       |
        v       v
    ............RRRRR  1.00
    ...........R.....  0.75
    ..........R......  0.50
    .........R.......  0.25
    RRRRRRRRR........  0.00
    ^       ^ ^     ^
    -1      0 |    +1
            +0.25

Green:

      -0.5    +0.5
        |       |
        v       v
    ....GGGGGGGGG....  1.00
    ...G.........G...  0.75
    ..G...........G..  0.50
    .G.............G.  0.25
    G........+......G  0.00
    ^       ^       ^
    -1      0      +1


Blue:

      -0.5    +0.5
        |       |
        v       v
    BBBBB............  1.00
    .....B...........  0.75
    ......B..........  0.50
    .......B.........  0.25
    ........BBBBBBBBB  0.00
    ^     ^ ^       ^
    -1    | 0      +1
        -0.25

It can implemented in a few ways, the simpliest is probably naively.

We can re-write it as this GLSL one-liner:

    vec3 Map_HotToCold_MichaelPohoreski( float t )
    {
        return clamp((vec3(2.0) - abs(4.0*vec3(t) - vec3(4,2,0))), 0., 1.);
    }

Alternatively, this can be optimized for GPUs by modifying standard hue2rgb!

If have this hue2rgb function that implements HSV when S=1 and V=1 ...

    hue2rgb( float angle )
    {
        return clamp(abs(fract(vec3(a)+vec3(3,2,1)/3.)*6. - 3.) - 1., 0., 1.);
    }

... then we can get the HotCold coloring via a simple phase shift!

    vec3 Map_HotToCold_MichaelPohoreski_Hue( float t )
    {
        return hue2rgb( (1.-t)*2./3. );
    }


=== "Turbo" ===

Good made a Jet replacement with polynomial approximation to have
more uniform brightness.

Unfortunately it has the same problems as Jet.

=== Also See ===

Uber Colormaps
* https://matplotlib.org/stable/users/explain/colors/colormaps.html
* https://matplotlib.org/thirdpartypackages/#colormaps-and-styles
* https://github.com/kbinani/colormap-shaders
* Smaller subset GLSL Colormap JPG
  https://github.com/glslify/glsl-colormap
* Small sampling
  https://github.com/jgreitemann/colormap
* Scientific Color maps
  https://www.fabiocrameri.ch/colourmaps/

Jet
* https://stackoverflow.com/questions/7706339/grayscale-to-red-green-blue-matlab-jet-color-scale
* https://gorelik.net/2020/08/17/what-is-the-biggest-problem-of-the-jet-and-rainbow-color-maps-and-why-is-it-not-as-evil-as-i-thought/
* Spectral Colour Schemes 
  https://www.shadertoy.com/view/ls2Bz1
* Alan Zucconi's Blog
  Improving the Rainbow
  https://www.alanzucconi.com/2017/07/15/improving-the-rainbow/
  Improving the Rainbow – Part 2
  https://www.alanzucconi.com/2017/07/15/improving-the-rainbow-2/
* https://gist.github.com/mikhailov-work/0d177465a8151eb6ede1768d51d476c7 
* https://github.com/kbinani/colormap-shaders/blob/master/shaders/glsl/MATLAB_jet.frag
* https://blogs.egu.eu/divisions/gd/2017/08/23/the-rainbow-colour-map/

MATLAB Blogs
* https://blogs.mathworks.com/loren/2007/01/10/colormap-manipulations/
* https://blogs.mathworks.com/steve/2014/10/13/a-new-colormap-for-matlab-part-1-introduction/
* https://blogs.mathworks.com/steve/2014/10/20/a-new-colormap-for-matlab-part-2-troubles-with-rainbows/
* https://blogs.mathworks.com/steve/2014/11/12/a-new-colormap-for-matlab-part-3-some-reactions/
* https://blogs.mathworks.com/steve/2017/07/24/colormap-test-image/
* https://blogs.mathworks.com/steve/category/colormap/?s_tid=Blog_steve_Category

Better Color Maps
* matplotlib colormaps 
  https://www.shadertoy.com/view/WlfXRN

* https://github.com/BIDS/colormap/blob/master/colormaps.py
* https://bids.github.io/colormap/
* https://bids.github.io/colormap/images/screenshots/jet.png

Divergent Color Ramps/Palettes
* https://stackoverflow.com/questions/37482977/what-is-a-good-palette-for-divergent-colors-in-r-or-can-viridis-and-magma-b

Parula
A Better Default Colormap for Matplotlib | SciPy 2015 | Nathaniel Smith and Stéfan van der Walt
https://www.youtube.com/watch?v=xAoljeRJ3lU

* Parula Matlab Colormap 
  https://www.shadertoy.com/view/ddBSWG

* matplotlib colormaps + turbo 
  https://www.shadertoy.com/view/3lBXR3

* https://mathematica.stackexchange.com/questions/161647/how-to-mimic-matlab-parula-color-scheme-efficiently

Turbo
* https://research.google/blog/turbo-an-improved-rainbow-colormap-for-visualization/

Viridis
* "Why you should use Viridis and not Jet (rainbow) as a colormap"
  * https://www.domestic-engineering.com/drafts/viridis/viridis.html
  NOTE: This has a LOT of mistakes in it!

  Image:
  * https://www.domestic-engineering.com/drafts/viridis/faces.svg 
* "Somewhere Over the Rainbow: An Empirical Assessment of Quantitative Colormaps"
* https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
* https://observablehq.com/@flimsyhat/webgl-color-maps
* https://blog.habrador.com/2023/04/colormaps-overview-code-implementations-rainbow-virids.html

SDF Sine Wave
* Sine Wave with smoothstep 
  https://www.shadertoy.com/view/mscXz4

*/
    #define M_PI  (      3.14159265358979323846264338327950288)
    #define M_TAU (2.0 * 3.14159265358979323846264338327950288)

// Colors
    #define WHITE vec3(1.0)
    #define BLACK vec3(0.0)

// Prototypes
    vec3  hue2rgb( float t );
    float CharAlpha( vec2 vFragCoord, float fValue );
    float text3( out float len, float c1, float c2, float c3 );
    vec3  Print( vec3 vBackgroundColor, vec3 vTextColor, vec2 vFragCoord, float fChars );

    float sRGBtoLinear( float x ); 
    vec3 sRGBtoLinear3( vec3 sRGB );
    float YtoLstar( float Y );
    float sRGBToPerceivedLightness( vec3 sRGB );

    // Author: Ken Silverman
    // https://advsys.net/ken/download.htm#evaldraw
    // https://advsys.net/ken/evaltut/evaldraw_tut.htm
    vec3 Map_EvalDraw_KenSilverman( float t )
    {
        vec3 rgb = vec3(t-0.75, t-0.50, t-0.25);
        return exp(rgb*rgb * -8.);
    }

// === Jet Mapping ===

    // The infamous/famous "Jet" color mapping made popular by MATLAB.
    // 
    // The history of Jet/Parula is a comedy of errors:
    //
    //   1. MATLAB 4 used hsv() which is horrible.
    //   2. MATLAB 5 then switched to "jet" which is STILL horrible.
    //   3. MATLAB R2014b doubled down and switched to an even crappier version called "Parula". (Just use Viridus if you must.)
    //
    // As far as I can tell MATLAB has never officially published
    // or documented their Jet color palette -- only posted iamges with oddball resolution instead
    // of a standard 256xN or 1024xN resolution.
    //
    // * https://blogs.mathworks.com/loren/2007/01/10/colormap-manipulations/
    // * https://blogs.mathworks.com/steve/2014/10/13/a-new-colormap-for-matlab-part-1-introduction/
    // * https://blogs.mathworks.com/steve/2014/10/20/a-new-colormap-for-matlab-part-2-troubles-with-rainbows/
    // * https://blogs.mathworks.com/steve/2014/11/12/a-new-colormap-for-matlab-part-3-some-reactions/
    // * https://blogs.mathworks.com/steve/2017/07/24/colormap-test-image/
    // * https://blogs.mathworks.com/steve/category/colormap/?s_tid=Blog_steve_Category
    //
    // The color maps are officially documented here:
    // * https://www.mathworks.com/help/matlab/ref/colormap.html
    //
    // The oddball 430x24 image (ignoring the border) can be found here:
    // * https://www.mathworks.com/help/matlab/ref/colormap_jet.png
    //
    // An older version of the blog has this notification about Jet being the new default.
    // * https://blogs.mathworks.com/loren/2007/01/10/colormap-manipulations/
    //
    //    "MATLAB version 4, the default colormap was hsv.
    //     The hsv colormap starts and ends with red, making it is very hard to interpret colors as high or low.
    //     Starting in MATLAB 5, the default colormap is jet."
    //
    // With this oddball 434x342 image size (ignoring the border):
    // * https://blogs.mathworks.com/images/loren/73/colormapManip_14.png
    //
    // The blog
    // * A New Colormap for MATLAB – Part 2 – Troubles with Rainbows
    //   https://blogs.mathworks.com/steve/2014/10/20/a-new-colormap-for-matlab-part-2-troubles-with-rainbows/
    //
    // Has this oddball 434x45 image (without border):
    //   * https://blogs.mathworks.com/images/steve/2014/parula_part_2_01.png
    //
    // There is an unofficial listing of colors here:
    //   "MATLAB Jet Colour Pallete" (sic.)
    //   * https://bugs.launchpad.net/inkscape/+bug/236508
    //
    // /!\ NOTE: There is a popular variation where the ends are held high
    //           called "Hot To Cold". It is hue2rgb() inverted with
    //           a phase shift -- however you _probably_ ALSO DON'T want to
    //           use this due to loss of fidelity in the low and high ranges.
    //           
    //           See:
    //           * Map_HotToCold_MichaelPohoreski_v1()
    //           * Map_HotToCold_MichaelPohoreski_v2()
    //
    // For a one-linear see:
    // * Map_Jet_JoshuaFraser()
    //
    // Author: Michael Pohoreski
    // Copyright: CC0
    // Naive linear implementation.
    // This can be extended to be cubic.
    // See:
    //    jet colormap 
    //    https://www.shadertoy.com/view/3tlGD4
    vec3 Map_Jet_MATLAB( float t )
    {
        const vec3 K0 = vec3(0.0, 0.0, 0.5);
        const vec3 K1 = vec3(0.0, 0.0, 1.0);
        const vec3 K2 = vec3(0.0, 0.5, 1.0);
        const vec3 K3 = vec3(0.0, 1.0, 1.0);
        const vec3 K4 = vec3(0.5, 1.0, 0.5);
        const vec3 K5 = vec3(1.0, 1.0, 0.0);
        const vec3 K6 = vec3(1.0, 0.5, 0.0);
        const vec3 K7 = vec3(1.0, 0.0, 0.0);
        const vec3 K8 = vec3(0.5, 0.0, 0.0);
        const float w = 1./8.;
        /* */ vec3  c = vec3(0);
        
        /**/ if (t < 1./8.) { c = mix( K0, K1, 8.*(t - (0./8.)) ); }
        else if (t < 2./8.) { c = mix( K1, K2, 8.*(t - (1./8.)) ); }
        else if (t < 3./8.) { c = mix( K2, K3, 8.*(t - (2./8.)) ); }
        else if (t < 4./8.) { c = mix( K3, K4, 8.*(t - (3./8.)) ); }
        else if (t < 5./8.) { c = mix( K4, K5, 8.*(t - (4./8.)) ); }
        else if (t < 6./8.) { c = mix( K5, K6, 8.*(t - (5./8.)) ); }
        else if (t < 7./8.) { c = mix( K6, K7, 8.*(t - (6./8.)) ); }
        else /*          */ { c = mix( K7, K8, 8.*(t - (7./8.)) ); }
        
        return clamp( c, vec3(0), vec3(1) );
    }

    // Author: Peter Bennett
    // * https://web.archive.org/web/20130111133715/http://bytebash.com/2012/03/opengl-volume-rendering/
    //   "OpenGL Minecraft Style Volume Rendering"
    // NOTE: This can be simplied with an one-liner by Joshua Fraser.
    //       See: Map_Jet_JoshuaFraser().
    vec3 Map_Jet_PeterBennett( float t )
    {
        float k = 4.0 * t;
        float r = min( k - 1.5, -k + 4.5);
        float g = min( k - 0.5, -k + 3.5);
        float b = min( k + 0.5, -k + 2.5);
    
        return clamp(vec3(r,g,b), 0.0, 1.0);
    }

    // Author: Joshua Fraser
    // https://stackoverflow.com/a/46628410
    vec3 Map_Jet_JoshuaFraser( float t )
    {
        return clamp((vec3(1.5) - abs(4.0*vec3(t) + vec3(-3,-2,-1))), 0., 1.);
    }

// === Hot to Cold Mapping ===

    // Alan Zucconi _incorrectly_ calls this Jet Mapping
    // https://www.shadertoy.com/view/ls2Bz1
    //
    //     vec3 spectral_jet(float w)
    //     {
    //          // w: [400, 700]
    //          // x: [0,   1]
    //          float x = saturate((w - 400.0)/ 300.0);
    //          vec3 c;
    //
    //          if (x < 0.25)
    //              c = vec3(0.0, 4.0 * x, 1.0);
    //          else if (x < 0.5)
    //              c = vec3(0.0, 1.0, 1.0 + 4.0 * (0.25 - x));
    //          else if (x < 0.75)
    //              c = vec3(4.0 * (x - 0.5), 1.0, 0.0);
    //          else
    //              c = vec3(1.0, 1.0 + 4.0 * (0.75 - x), 0.0);
    //
    //          // Clamp colour components in [0,1]
    //          return saturate(c);
    //     }
    // 
    // See Desmos: 
    // * https://www.desmos.com/calculator/1u2pq8gdsw
    //
    // I cleaned up his version to be more readable.
    vec3 Map_HotToCold_AlanZucconi( float t )
    {
        vec3 c;
        float w = 4.0 * (0.75 - t); // Remap 0.75 .. 1.00 --> 1.0 .. 0.0
        float x = 4.0 * (t - 0.50); // Remap 0.50 .. 0.75 --> 0.0 .. 1.0
        float y = 4.0 * (t       ); // Remap 0.00 .. 0.25 --> 0.0 .. 1.0
        float z = 4.0 * (0.25 - t); // Remap 0.25 .. 0.75 --> 1.0 .. 0.0
    
        /**/ if (t < 0.25) c = vec3(0.0,   y    , 1.0);
        else if (t < 0.50) c = vec3(0.0, 1.0    , 1.0 + z);
        else if (t < 0.75) c = vec3(  x, 1.0    , 0.0);
        else /*         */ c = vec3(1.0, 1.0 + w, 0.0);
    
        return clamp(c, vec3(0.0), vec3(1.0));
    }

    // We can get rid of the conditionals in
    //   Map_HotToCold_AlanZucconi()
    // by looking at the linear equations.
    //
    // https://www.desmos.com/calculator/1u2pq8gdsw
    //     Unclamped r  =       4.0*(x - 0.50)
    //     Unclamped g1 =       4.0*(x       )
    //     Unclamped g2 = 1.0 + 4.0*(0.75 - x)
    //     Unclamped b  = 1.0 + 4.0*(0.25 - x)
    //
    // Also see:
    //
    //        // Map_HotToCold_MichaelPohoreski_v1()
    //        hue2rgb( (1.-q.x)*2./3. );                                   
    //
    //        // Map_HotToCold_MichaelPohoreski_v2()
    //        clamp((vec3(2.0) - abs(4.0*vec3(t) - vec3(4,2,0))), 0., 1.); 
    vec3 Map_HotToCold_MichaelPohoreski_v0( float t )
    {                                      // Eventually we can rewrite as:
        float r =            4.0*(t-0.50); // -> 2.0 - abs(4.0*t - 4)
        float g = 2.0 - abs((4.0*t)-2.0 ); // -> 2.0 - abs(4.0*t - 2)
        float b = 1.0 +      4.0*(0.25-t); // -> 2.0 - abs(4.0*t - 0)
        vec3  c = vec3(r,g,b);
        return clamp(c, vec3(0.0), vec3(1.0));
    }

    // Author: Michael Pohoreski
    // Copyright: CC0
    // Alternative easy to remember one-liner (!)
    vec3 Map_HotToCold_MichaelPohoreski_Hue( float t )
    {
        return hue2rgb( (1.-t)*2./3. );
    }

    // Author: Michael Pohoreski
    // Copyright: CC0
    // Continuing to factor and simply "v0" we end up with this one-liner.
    vec3 Map_HotToCold_MichaelPohoreski( float t )
    {
        return clamp((vec3(2.0) - abs(4.0*vec3(t) - vec3(4,2,0))), 0., 1.);
    }

    // Author: Michael Pohoreski
    // Copyright: CC0
    // Reference:
    // * https://stackoverflow.com/questions/7706339/grayscale-to-red-green-blue-matlab-jet-color-scale/
    //
    // In : t is a normalized percentage [0.0 .. 1.0]
    // Out: R = centered around 100%, solid width 25%
    // Out: G = centered around  50%, solid width 50% 
    // Out: B = centered around   0%, solid width 25%
    //
    // Jet       has 8 "columns"
    // HotToCold has 4 "columns"
    vec3 Map_HotToCold_Manual( float t )
    {
        float w = 0.25; // 4 "columns", width 25%
        float R = (t <  0.50) ? 0.0
                : (t >= 0.75) ? 1.0
                : ((t - 0.50) / w);
        float G = (t <  0.25) ?        (t         / w)
                : (t >= 0.75) ? 1.0 - ((t - 0.75) / w)
                : 1.0;
        float B = (t >= 0.50) ? 0.0
                : (t <  0.25) ? 1.0
                : 1.0 - ((t - 0.25) / w);
        return vec3(R,G,B);
    }

    // https://stackoverflow.com/a/56678483
    vec3 Map_sRGBToPerceivedLightness( float t )
    {
        return vec3( sRGBToPerceivedLightness( vec3(t) ) );
    }

    // https://observablehq.com/@flimsyhat/webgl-color-maps
    // See: https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/blob/master/color-advice/inferno/inferno.ipynb
    //      https://github.com/BIDS/colormap/blob/master/colormaps.py
    vec3 Map_Inferno( float t )
    {
        const vec3 c0 = vec3(  0.0002189403691192265,   0.001651004631001012,  -0.01948089843709184);
        const vec3 c1 = vec3(  0.1065134194856116   ,   0.5639564367884091  ,   3.932712388889277  );
        const vec3 c2 = vec3( 11.60249308247187     ,  -3.972853965665698   , -15.9423941062914    );
        const vec3 c3 = vec3(-41.70399613139459     ,  17.43639888205313    ,  44.35414519872813   );
        const vec3 c4 = vec3( 77.162935699427       , -33.40235894210092    , -81.80730925738993   );
        const vec3 c5 = vec3(-71.31942824499214     ,  32.62606426397723    ,  73.20951985803202   );
        const vec3 c6 = vec3( 25.13112622477341     , -12.24266895238567    , -23.07032500287172   );
    
        return c0 + t*(c1 + t*(c2 + t*(c3 + t*(c4 + t*(c5 + t*c6)))));
    }

    // https://observablehq.com/@flimsyhat/webgl-color-maps
    // See: https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/blob/master/color-advice/magma/magma.ipynb
    //      https://github.com/BIDS/colormap/blob/master/colormaps.py
    vec3 Map_Magma( float t )
    {
        const vec3 c0 = vec3( -0.002136485053939582,  -0.000749655052795221,  -0.005386127855323933);
        const vec3 c1 = vec3(  0.2516605407371642  ,   0.6775232436837668  ,   2.494026599312351   );
        const vec3 c2 = vec3(  8.353717279216625   ,  -3.577719514958484   ,   0.3144679030132573  );
        const vec3 c3 = vec3(-27.66873308576866    ,  14.26473078096533    , -13.64921318813922    );
        const vec3 c4 = vec3( 52.17613981234068    , -27.94360607168351    ,  12.94416944238394    );
        const vec3 c5 = vec3(-50.76852536473588    ,  29.04658282127291    ,   4.23415299384598    );
        const vec3 c6 = vec3( 18.65570506591883    , -11.48977351997711    ,  -5.601961508734096   );
    
        return c0 + t*(c1 + t*(c2 + t*(c3 + t*(c4 + t*(c5 + t*c6)))));
    }

    // Author: wagyx
    // Copyright: CC0
    //
    // First, you'll want to read the History of Jet (above).
    // Second, you _probably_ want to use Viridus but if you MUST use
    // (a palette close to) Parula then there is BAD news and GOOD news.
    //
    // /!\ Parula is IP of Mathworks. 
    //     Do NOT USE algorithms when companies love to pretend to "own" numbers.
    //
    //     https://discourse.matplotlib.org/t/matlab-parula-colormap/18870/7
    //        "The colormap is, however, MathWorks intellectual property,
    //        and it would not be appropriate or
    //        acceptable to copy or re-use it in non-MathWorks plotting tools."
    //
    // /!\ There IS a CC0 version by wagyx that is free to use!
    //
    //     Parula MATLAB Colormap 
    //     https://www.shadertoy.com/view/ddBSWG
    //
    // http://blogs.mathworks.com/steve/2014/10/13/a-new-colormap-for-matlab-part-1-introduction/
    //     "I believe it was almost four years ago that we started kicking around the
    //      idea of changing the default colormap in MATLAB. Now, with the major update
    //      of the MATLAB graphics system in R2014b, the colormap change has finally happened."
    // https://blogs.mathworks.com/steve/2014/10/20/a-new-colormap-for-matlab-part-2-troubles-with-rainbows/
    //
    // There is this hard-coded WTF implementation at:
    // * https://github.com/kbinani/colormap-shaders/blob/master/shaders/glsl/MATLAB_parula.frag
    //
    // Sixth-order polynomial
    vec3 Map_Parula_Wagyx6( float t )
    {
        const vec3 c6 = vec3( 1.06652837e+02, -1.07075762e+01, -8.37729675e+01);
        const vec3 c5 = vec3(-3.25068057e+02,  3.87339330e+01,  2.38466727e+02);
        const vec3 c4 = vec3( 3.54679594e+02, -4.51177381e+01, -2.53217221e+02);
        const vec3 c3 = vec3(-1.63995733e+02,  1.97284255e+01,  1.28751410e+02);
        const vec3 c2 = vec3( 3.02928593e+01, -3.22651412e+00, -3.63808525e+01);
        const vec3 c1 = vec3(-1.89612390e+00,  1.47390611e+00,  5.58086436e+00);
        const vec3 c0 = vec3( 2.85251835e-01,  1.37220184e-01,  6.17373938e-01);
        return c0 + t*(c1 + t*(c2 + t*(c3 + t*(c4 + t*(c5 + t*c6)))));
    }

    // https://observablehq.com/@flimsyhat/webgl-color-maps
    // See: https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/blob/master/color-advice/plasma/plasma.ipynb
    //      https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/blob/master/color-advice/plasma/plasma-original.json
    //      https://github.com/BIDS/colormap/blob/master/colormaps.py
    // Sixth-order polynomial
    vec3 Map_Plasma( float t )
    {
        const vec3 c0 = vec3(  0.05873234392399702,   0.02333670892565664,   0.5433401826748754);
        const vec3 c1 = vec3(  2.176514634195958  ,   0.2383834171260182 ,   0.7539604599784036);
        const vec3 c2 = vec3( -2.689460476458034  ,  -7.455851135738909  ,   3.110799939717086 );
        const vec3 c3 = vec3(  6.130348345893603  ,  42.3461881477227    , -28.51885465332158  );
        const vec3 c4 = vec3(-11.10743619062271   , -82.66631109428045   ,  60.13984767418263  );
        const vec3 c5 = vec3( 10.02306557647065   ,  71.41361770095349   , -54.07218655560067  );
        const vec3 c6 = vec3( -3.658713842777788  , -22.93153465461149   ,  18.19190778539828  );
    
        return c0 + t*(c1 + t*(c2 + t*(c3 + t*(c4 + t*(c5 + t*c6)))));
    }

    // Author: Michael Pohoreski
    // Copyright: CC0
    // Looking at the RGB curves for Jet ...
    //    https://i.sstatic.net/W0zuo.png
    // we notice they look a lot like a sine wave.
    // We can instead use a sine wave with a phase offset and translation.
    // You DON'T want to use a "natural" spread of 1/3, 2/3, 0/3.
    vec3 Map_SineJet_MichaelPohoreski( float t )
    {
        float rad =              t  * M_TAU   ;
        float r = sin( rad + (2./4. * M_TAU) );
        float g = sin( rad + (3./4. * M_TAU) );
        float b = sin( rad + (0./4. * M_TAU) );
        return 0.5 + 0.5*vec3(r,g,b);
    }
    
    // Author: Michael Pohoreski
    // Looking at the RGB curves for Jet we can instead
    // use a sine wave with a phase offset.
    // Also see: 
    // * Map_SineJet_MichaelPohoreski()
    vec3 Map_SineEnigma_MichaelPohoreski( float t )
    {
        float rad =              t  * M_TAU  ;
        float r = sin( rad + (2./4. * M_PI) );
        float g = sin( rad + (1./4. * M_PI) );
        float b = sin( rad + (0./4. * M_PI) );
        return 0.5 + 0.5*vec3(r,g,b);
    }

    /*
    // Copyright 2019 Google LLC.
    // SPDX-License-Identifier: Apache-2.0
    
    // Polynomial approximation in GLSL for the Turbo colormap
    // Original LUT: https://gist.github.com/mikhailov-work/ee72ba4191942acecc03fe6da94fc73f

    // Authors:
    //   Colormap Design: Anton Mikhailov (mikhailov@google.com)
    //   GLSL Approximation: Ruofei Du (ruofei@google.com)
    vec3 TurboColormap(in float x) {
      const vec4 kRedVec4 = vec4(0.13572138, 4.61539260, -42.66032258, 132.13108234);
      const vec4 kGreenVec4 = vec4(0.09140261, 2.19418839, 4.84296658, -14.18503333);
      const vec4 kBlueVec4 = vec4(0.10667330, 12.64194608, -60.58204836, 110.36276771);
      const vec2 kRedVec2 = vec2(-152.94239396, 59.28637943);
      const vec2 kGreenVec2 = vec2(4.27729857, 2.82956604);
      const vec2 kBlueVec2 = vec2(-89.90310912, 27.34824973);
      
      x = saturate(x);
      vec4 v4 = vec4( 1.0, x, x * x, x * x * x);
      vec2 v2 = v4.zw * v4.z;
      return vec3(
        dot(v4, kRedVec4)   + dot(v2, kRedVec2),
        dot(v4, kGreenVec4) + dot(v2, kGreenVec2),
        dot(v4, kBlueVec4)  + dot(v2, kBlueVec2)
      );
    }
    */
    vec3 Map_Turbo_Google( float t )
    {
        const vec4 kRedVec4   = vec4(   0.13572138,  4.61539260, -42.66032258, 132.13108234);
        const vec4 kGreenVec4 = vec4(   0.09140261,  2.19418839,   4.84296658, -14.18503333);
        const vec4 kBlueVec4  = vec4(   0.10667330, 12.64194608, -60.58204836, 110.36276771);
        const vec2 kRedVec2   = vec2(-152.94239396, 59.28637943);
        const vec2 kGreenVec2 = vec2(   4.27729857,  2.82956604);
        const vec2 kBlueVec2  = vec2( -89.90310912, 27.34824973);
        float x = clamp(t, 0.0, 1.0);
        vec4 v4 = vec4( 1.0, x, x*x, x*x*x);
        vec2 v2 = v4.zw * v4.z;
        return vec3(
            dot(v4, kRedVec4  ) + dot(v2, kRedVec2  ),
            dot(v4, kGreenVec4) + dot(v2, kGreenVec2),
            dot(v4, kBlueVec4 ) + dot(v2, kBlueVec2 )
        );
    }

    // Testing turbo colormap
    // https://www.shadertoy.com/view/3t2XzV
    //
    // Also see:
    //     Fifth-order polynomial approximation of Turbo based on:
    //     https://observablehq.com/@mbostock/turbo
    //         function interpolateTurbo(x) {
    //         x = Math.max(0, Math.min(1, x));
    //         return `rgb(${[
    //             34.61 + x * (1172.33 - x * (10793.56 - x * (33300.12 - x * (38394.49 - x * 14825.05)))),
    //             23.31 + x * (557.33 + x * (1225.33 - x * (3574.96 - x * (1073.77 + x * 707.56)))),
    //             27.2 + x * (3211.1 - x * (15327.97 - x * (27814 - x * (22569.18 - x * 6838.66))))
    //         ].map(Math.floor).join(", ")})`;
    //     }
    // And:
    //     https://gist.github.com/mikhailov-work/0d177465a8151eb6ede1768d51d476c7
    vec3 Map_Turbo_Maeln(float x)
    {
        float r = 0.1357 + x*( 4.5974 - x*(42.3277 - x*( 130.5887 - x*(150.5666 - x*58.1375 ))));
        float g = 0.0914 + x*( 2.1856 + x*( 4.8052 - x*( 14.0195  - x*(  4.2109 + x* 2.7747 ))));
        float b = 0.1067 + x*(12.5925 - x*(60.1097 - x*(109.0745  - x*( 88.5066 - x*26.8183 ))));
    
        return vec3(r,g,b);
    }

    // https://observablehq.com/@flimsyhat/webgl-color-maps
    // See: https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/tree/master/color-advice/viridis
    //      https://github.com/kennethmoreland-com/kennethmoreland-com.github.io/blob/master/color-advice/viridis/viridis-original.json
    //      https://github.com/BIDS/colormap/blob/master/colormaps.py
    vec3 Map_Viridus( float t )
    {
        const vec3 c0 = vec3( 0.2777273272234177,  0.005407344544966578,   0.3340998053353061 );
        const vec3 c1 = vec3( 0.1050930431085774,  1.404613529898575   ,   1.384590162594685  );
        const vec3 c2 = vec3(-0.3308618287255563,  0.214847559468213   ,   0.09509516302823659);
        const vec3 c3 = vec3(-4.634230498983486 , -5.799100973351585   , -19.33244095627987   );
        const vec3 c4 = vec3( 6.228269936347081 , 14.17993336680509    ,  56.69055260068105   );
        const vec3 c5 = vec3( 4.776384997670288 ,-13.74514537774601    , -65.35303263337234   );
        const vec3 c6 = vec3(-5.435455855934631 ,  4.645852612178535   ,  26.3124352495832    );
    
        return c0 + t*(c1 + t*(c2 + t*(c3 + t*(c4 + t*(c5 + t*c6)))));
    }

// === Perceived Lightness ===

    // https://stackoverflow.com/a/56678483
    // Input : decimal sRGB gamma encoded color value between 0.0 and 1.0
    // Output: linearized value.
    float sRGBtoLinear( float x ) 
    {
        if (x <= 0.04045) return x / 12.92;
        return pow(((x + 0.055) / 1.055), 2.4);
    }

    vec3 sRGBtoLinear3( vec3 sRGB )
    {
        return vec3(
            sRGBtoLinear( sRGB.r ),
            sRGBtoLinear( sRGB.g ),
            sRGBtoLinear( sRGB.b )
        );
    }

    // Convert Luminance to L* perceptual lightness
    float YtoLstar( float Y )
    {
        if ( Y <= (216./24389.))          // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036 
            return Y * (24389./27.);      // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
        return pow(Y,(1./3.))*116. - 16.;
    }

    // https://stackoverflow.com/a/56678483
    float sRGBToPerceivedLightness( vec3 sRGB )
    {
        vec3 linear = sRGBtoLinear3( sRGB );
        float Y     = (0.2126*linear.r + 0.7152*linear.g + 0.0722*linear.b);
        float Ystar = YtoLstar( Y );
        return Ystar / 100.;
    }

// === Color Mapping ===

vec3 Map( float t, float type )
{                                                                   // Also see:
    /**/ if (type < 1.0) return Map_Jet_MATLAB                 (t); //   Map_Jet_PeterBennett, Map_Jet_JoshuaFraser
    else if (type < 2.0) return Map_Turbo_Google               (t); //   Map_Turbo_Maeln()
    else if (type < 3.0) return Map_SineJet_MichaelPohoreski   (t); //   
    else if (type < 4.0) return Map_EvalDraw_KenSilverman      (t); //   
    else if (type < 5.0) return Map_HotToCold_MichaelPohoreski (t); //   Map_HotToCold_AlanZucconi
    else if (type < 6.0) return Map_SineEnigma_MichaelPohoreski(t); //   
    else if (type < 7.0) return Map_sRGBToPerceivedLightness   (t); //
    else if (type < 8.0) return Map_Inferno                    (t); //
    else if (type < 9.0) return Map_Magma                      (t); //
    else if (type <10.0) return Map_Plasma                     (t); //
    else if (type <11.0) return Map_Parula_Wagyx6              (t); //
    else /*           */ return Map_Viridus                    (t); //   Map_Parula_Wagyx6
}

vec3 Status( float type, vec3 colorBG, vec3 colorFG, vec2 p )
{
    float len, k;
    vec3  color = colorBG;
#if FONT
#if FULL_STATUS
    if (type < 1.0) // "Jet" by MATLAB
    {
        color = Print( color, colorFG, p, text3( len, 74.0, 69.0, 84.0 ) );
    }
    else
    if (type < 2.0) // "Turbo" by Google
    {
        color = Print( color, colorFG, p, text3( len, 84.0, 85.0, 82.0 ) );
        color = Print( color, colorFG, p, text3( len, 66.0, 79.0,  0.0 ) );
    }
    else
    if (type < 3.0) // "Sine Jet" by Michael Pohoreski
    {
        color = Print( color, colorFG, p, text3( len, 83.0, 73.0, 78.0 ) );
        color = Print( color, colorFG, p, text3( len, 69.0, 32.0, 74.0 ) );
        color = Print( color, colorFG, p, text3( len, 69.0, 84.0,  0.0 ) );
    }
    else
    if (type < 4.0) // "EvalDraw" by Ken Silverman
    {
        color = Print( color, colorFG, p, text3( len, 69.0, 86.0, 65.0 ) );
        color = Print( color, colorFG, p, text3( len, 76.0, 68.0, 82.0 ) );
        color = Print( color, colorFG, p, text3( len, 65.0, 87.0, 32.0 ) );
    }
    else
    if (type < 5.0) // "HOT COLD"
    {
        color = Print( color, colorFG, p, text3( len, 72.0, 79.0, 84.0 ) );
        color = Print( color, colorFG, p, text3( len, 32.0, 67.0, 79.0 ) );
        color = Print( color, colorFG, p, text3( len, 76.0, 68.0,  0.0 ) );
    }
    else
    if (type < 6.0) // "Sine Enigma" by Michael Pohoreski
    {
        color = Print( color, colorFG, p, text3( len, 83.0, 73.0, 78.0 ) );
        color = Print( color, colorFG, p, text3( len, 69.0, 32.0, 69.0 ) );
        color = Print( color, colorFG, p, text3( len, 78.0, 73.0, 71.0 ) );
        color = Print( color, colorFG, p, text3( len, 77.0, 65.0,  0.0 ) );
    }
    else
    if (type < 7.0) // "B&W"
    {
        color = Print( color, colorFG, p, text3( len, 66.0, 38.0, 87.0 ) );
    }
    else
    if (type < 8.0) // "Inferno"
    {
        color = Print( color, colorFG, p, text3( len, 73.0, 78.0, 70.0 ) );
        color = Print( color, colorFG, p, text3( len, 69.0, 82.0, 78.0 ) );
        color = Print( color, colorFG, p, text3( len, 79.0,  0.0,  0.0 ) );
    }
    else
    if (type < 9.0) // "Magma"
    {
        color = Print( color, colorFG, p, text3( len, 77.0, 65.0, 71.0 ) );
        color = Print( color, colorFG, p, text3( len, 77.0, 65.0,  0.0 ) );
    }
    else
    if (type < 10.0) // "Plasma"
    {
        color = Print( color, colorFG, p, text3( len, 80.0, 76.0, 65.0 ) );
        color = Print( color, colorFG, p, text3( len, 83.0, 77.0, 65.0 ) );
    }
    else
    if (type < 11.0) // "Parula"
    {
        color = Print( color, colorFG, p, text3( len, 80.0, 65.0, 82.0 ) );
        color = Print( color, colorFG, p, text3( len, 85.0, 76.0, 65.0 ) );
    }
    else 
    if (type < 12.0) // "Viridus"
    {
        color = Print( color, colorFG, p, text3( len, 86.0, 73.0, 82.0 ) );
        color = Print( color, colorFG, p, text3( len, 73.0, 68.0, 85.0 ) );
        color = Print( color, colorFG, p, text3( len, 83.0,  0.0,  0.0 ) );
    }
    else // "---"
    {
        color = Print( color, colorFG, p, text3( len, 45.0, 45.0, 45.0 ) ); 
    }

#endif // FULL_STATUS
#endif // FONT
    return color;
}
    // @param t -- Normalized Angle [0.0 .. 1.0]
    // R = centered around 0/3 (wrap)
    // G = centered around 1/3 (wrap)
    // B = centered around 2/3 (wrap)
    vec3 hue2rgb(float t)
    {
        return clamp(abs(fract(vec3(t)+vec3(3,2,1)/3.)*6. - 3.) - 1., 0., 1.);
    }

// ---- FONT ----------------------------------------------------------------

vec3 PutChar( vec3 vBackgroundColor, vec3 vTextColor, vec2 vFragCoord, float fValue );

// Creative Commons CC0 1.0 Universal (CC-0)
// Based on:
// https://www.shadertoy.com/view/4sBSWW

/* */ vec2  gvFontSize    = vec2(4.0, 15.0); // Multiples of 4x5 work best
/* */ vec2  gvPrintCharXY = vec2( 0.0, 0.0 ); // in pixels, NOT normalized
const float nPrintDelta = 32.0;
const float nPrintShift = 96.0;

float center( float glyphWidth, float numChars )
{
    return (glyphWidth - numChars*gvFontSize.x) * 0.5;
}

#if FONT
// x = ASCII value in decimal
// Bits are left-to-right, 4x5
float GlyphBin(const in int x)
{
    if (x < 32)
        return 0.0;
    if (x < 47)
        return // Glyphs added by Michael Pohoreski
             x==32 ?      0.0
            :x==33 ? 139778.0 // '!' 0x21
            :x==38 ? 152154.0 // '&' 0x25
            :x==42 ?  21072.0 // '*' 0x2A
            :x==45 ?   3840.0 // '-' 0x2D
            :/* 46*/      2.0 // '.' 0x2E
            ;
    if (x < 58)
        return // Mostly original glyphs
             x==48 ? 480599.0 // '0' 0x30
            :x==49 ? 143911.0 // '1' 0x31 // Original sans serif "|": 139810.0, Custom serif "1": 143911.0
            :x==50 ? 476951.0 // '2' 0x32 
            :x==51 ? 476999.0 // '3' 0x33 
            :x==52 ? 350020.0 // '4' 0x34 
            :x==53 ? 464711.0 // '5' 0x35 
            :x==54 ? 464727.0 // '6' 0x36 
            :x==55 ? 476228.0 // '7' 0x37 
            :x==56 ? 481111.0 // '8' 0x38 
            :/* 57*/ 481095.0 // '9' 0x39
            ;
    else
    if (x < 78)
        return // Glyphs added by Michael Pohoreski
             x==61 ?  61680.0 // '=' 0x3D
            :x==65 ? 434073.0 // 'A' 0x41
            :x==66 ? 497559.0 // 'B' 0x42
            :x==67 ? 921886.0 // 'C' 0x43
            :x==68 ? 498071.0 // 'D' 0x44
            :x==69 ? 988959.0 // 'E' 0x45
            :x==70 ? 988945.0 // 'F' 0x46
            :x==71 ? 925086.0 // 'G' 0x47
            :x==72 ? 630681.0 // 'H' 0x48
            :x==73 ? 467495.0 // 'I' 0x49
            :x==74 ? 559239.0 // 'J' 0x4A
            :x==75 ? 611161.0 // 'K' 0x4B
            :x==76 ?  69919.0 // 'L' 0x4C
            :/* 77*/ 653721.0 // 'M' 0x4D
            ;
    else
    if (x < 91)
        return // Glyphs added by Michael Pohoreski
             x==78 ? 638361.0 // 'N' 0x4E
            :x==79 ? 432534.0 // 'O' 0x4F // width=4, 432534; width=3 152914
            :x==80 ? 497425.0 // 'P' 0x50
            :x==81 ? 432606.0 // 'Q' 0x51
            :x==82 ? 497561.0 // 'R' 0x52
            :x==83 ? 923271.0 // 'S' 0x53
            :x==84 ? 467490.0 // 'T' 0x54
            :x==85 ? 629142.0 // 'U' 0x55
            :x==86 ? 349474.0 // 'V' 0x56
            :x==87 ? 629241.0 // 'W' 0x57
            :x==88 ? 628377.0 // 'X' 0x58
            :x==89 ? 348706.0 // 'Y' 0x59
            :/* 90*/ 475671.0 // 'Z' 0x5A
            ;
    else
    if (x < 127)
        return
          x ==101 ?  10006.0 // 'e' 0x65
         :x ==102 ? 272162.0 // 'f' 0x66
         :x ==104 ?  70485.0 // 'h' 0x68
         :x ==105 ? 131618.0 // 'i' 0x69
         :x ==110 ?    853.0 // 'n' 0x6E
         :x ==116 ? 141092.0 // 't' 0x74
         :x ==127 ? 678490.0 //     0x7F
         :               0.0
         ;
    return 0.0;
}


// Returns alpha of character
// ==================================================
float CharAlpha( vec2 vFragCoord, float fValue )
{
    vec2 vStringCharCoords = (vFragCoord.xy - gvPrintCharXY) / gvFontSize;
    if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0; // backgroundColor;
    if ( vStringCharCoords.x < 0.0)                                  return 0.0; // backgroundColor;

    fValue += nPrintDelta;
    float fCharBin = (vStringCharCoords.x < 1.0) ? GlyphBin(int(fValue)) : 0.0;

    // Auto-Advance cursor one glyph plus 1 pixel padding
    // thus characters are spaced 9 pixels apart
    float fAdvance = false
        || (fValue == 42.) // *
        || (fValue == 73.) // I
        || (fValue == 84.) // T
        || (fValue == 86.) // V
        || (fValue == 89.) // Y
        || (fValue ==104.) // h
        || (fValue ==105.) // i
        || (fValue ==116.) // t
        ? 0.0 // glyph width has no padding
        : 2.0; // NOTE: Changed from 1 for 4K displays
    if( fValue == 33.) // !
        fAdvance = -(gvFontSize.x / 6.0);
    gvPrintCharXY.x += gvFontSize.x + fAdvance;

    // a = floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));
    //return mix( backgroundColor, textColor, a );

    return floor(
        mod(
            (fCharBin / pow(
                2.0,
                floor(fract(vStringCharCoords.x) * 4.0) +
                (floor(vStringCharCoords.y * 5.0) * 4.0))),
            2.0
        )
    );
}

/*
   Print a maximum of 3 characters
       = floating-point 24-bits mantissa / 7-bits/char
       = 3.42... chars
*/
// ==================================================
vec3 Print( vec3 vBackgroundColor, vec3 vTextColor, vec2 vFragCoord, float fChars )
{
    vec3  color = vBackgroundColor;
    float bits  = fChars;

    for( int i = 0; i < 3; i++ )
    {
        float nChar = mod( bits, nPrintShift );
        nChar += nPrintDelta;
        if( nChar < 32.0 )
            break;

        bits /= nPrintShift;
        bits = floor( bits );

        color = PutChar( color, vTextColor, vFragCoord, nChar );
    }
    return color;
}

//float PrintValue(...)
//  const in vec2  fragCoord      -- in screen space
//  const in vec2  vPixelCoords   -- in screen space
//  const in vec2  vFontSize      -- in screen space
//  const in float fValue         -- value to print
//  const in float fMaxDigits     --
//  const in float fDecimalPlaces -- number of digits after decimal
// @returns monochrome color
// ==================================================
float PrintValue(const in vec2 fragCoord, const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
    vec2 vStringCharCoords = (fragCoord.xy - vPixelCoords) / vFontSize;
    if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0;
    float fLog10Value = log2(abs(fValue)) / log2(10.0);
    float fBiggestIndex = max(floor(fLog10Value), 0.0);
    float fDigitIndex = fMaxDigits - floor(vStringCharCoords.x);
    float fCharBin = 0.0;
    if(fDigitIndex > (-fDecimalPlaces - 1.01)) {
        if(fDigitIndex > fBiggestIndex) {
            if((fValue < 0.0) && (fDigitIndex < (fBiggestIndex+1.5))) fCharBin = 1792.0;
        } else {
            if(fDigitIndex == -1.0) {
                if(fDecimalPlaces > 0.0) fCharBin = 2.0;
            } else {
                if(fDigitIndex < 0.0) fDigitIndex += 1.0;
                float fDigitValue = (abs(fValue / (pow(10.0, fDigitIndex))));
                float kFix = 0.0001;
                fCharBin = GlyphBin( 48 + int(floor(mod(kFix+fDigitValue, 10.0))));
            }
        }
    }
    return floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));
}

/*
Usage:
    // void mainImage( out vec4 fragColor, in vec2 fragCoord )

    vec3 colorBG  = vec3( 1 );
    vec3 colorFG  = vec3( 0 );
    vec3 color;

    vec2 centerXY = iResolution.xy * 0.5;
    gvPrintCharXY = vec2( centerXY );

    float len;
    float text = text3( len, 65.0, 66.0, 67.0 );
    color = PutChar( colorBG, colorFG, fragCoord, text ); // "ABC"

    text = text3( len, 88.0, 89.0, 90.0 );
    color = mix(     color  , colorFG, fragCoord, text ); // "XYZ"

    fragColor.rgb = color;
*/
// ==================================================
vec3 PutChar( vec3 vBackgroundColor, vec3 vTextColor, vec2 vFragCoord, float fValue )
{
    float a = CharAlpha( vFragCoord, fValue - nPrintDelta );
    return mix( vBackgroundColor, vTextColor, a );
}
#endif

// Pack 3 chars into 24-bit float mantissa
// ==================================================
float text3( out float len, float c1, float c2, float c3 )
{
    float s = 1.0;
    float t = nPrintShift;

    float text     = 0.0;
    float numChars = 0.0;

    if( c1 > 0.0) { numChars += 1.0; text += s*(c1 - nPrintDelta); s *= t; }
    if( c2 > 0.0) { numChars += 1.0; text += s*(c2 - nPrintDelta); s *= t; }
    if( c3 > 0.0) { numChars += 1.0; text += s*(c3 - nPrintDelta); s *= t; }

    len = numChars;
    return text;
}

// We set num types to be double num bars to make it visually easy
// to "pick" the right algorith
#define NUM_BARS    6.0 // bars
#define NUM_TYPES  12.0 // algorithms

// NOTE: We are extending hueDegreesBG to include:
//   Hue  Degrees
//   R  =   0
//    Y =  60
//   G  = 120
//    C = 180
//   B  = 240
//    M = 300 
//   K  =-360 Custom extension
//    W =+360 Custom extension
// ==================================================
vec3 Labels( vec3 background, vec2 p, float topY, float hueDegreesBG )
{
    vec3 color    = background;
#if LABELS
#if FONT
    vec2  q       = p / iResolution.xy;
    float h       = 1.0 / NUM_BARS;
    float scaleY  = (gvFontSize.y / iResolution.y);
    float row     = (topY - 1.0) * h;
    float nTopY   = row   * iResolution.y; // pixels
    float nBotY   = nTopY + gvFontSize.y;  // pixels
    float centerY = ((iResolution.y * h) - gvFontSize.y) * 0.5; // pixels

    vec3  colorBG  = (hueDegreesBG <= -360.) ? BLACK
                   : (hueDegreesBG >= +360.) ? WHITE
                                             : hue2rgb( hueDegreesBG / 360. );

    float text = 0.0;
    float len  = 0.0;

    gvPrintCharXY.xy = vec2( gvFontSize.x, nTopY + centerY ); // pixels

    // Show '#'
    if (p.x <= (gvFontSize.x * 3.0))
    {
        text = text3( len, 48.0 + (NUM_BARS - topY + 1.0), 0.0, 0.0 ); // '1' .. '6'
        color = Print( colorBG, vec3(1) - colorBG, p, text );
    }
#endif // FONT
#endif // LABELS
    return color;
}

#define NUM_COLS  3.0

// ==================================================
void mainImage( out vec4 fragColor, in vec2 p )
{
    if( iResolution.x >  512.) gvFontSize.x *= 2.0;
    if( iResolution.x > 2048.) gvFontSize.x *= 2.0;
    
    vec2  q           = p/iResolution.xy; // Normalized pixel coordinates (from 0 to 1)
    bool  bLeftClick  = iMouse.z > 0.5;
    vec2  mouse       = iMouse.xy / iResolution.xy;
    float type        = clamp( floor(NUM_TYPES * mouse.y), 0.0, NUM_TYPES-1.);
    bool  bModePhoto  = (iMouse.x < iResolution.x*1./NUM_COLS);
    bool  bModeCurves = (iMouse.x > iResolution.x*2./NUM_COLS);
    bool  bShowLabels =  bLeftClick && !bModeCurves;
    bool  bSlideshow  = !bLeftClick;

    if (bSlideshow)
    {
        #define LEN_SEGMENTS 6.0 // seconds
        #define NUM_SEGMENTS 3.0

        float timeR = mod( iTime, (LEN_SEGMENTS * NUM_SEGMENTS) );
        bool  bPrev = (mod( timeR, LEN_SEGMENTS ) <= q.x); // 1 second wipe, N-1 seconds static image
        float slide = floor( timeR / LEN_SEGMENTS);
        if (slide == 0.0)
        {
            if (bPrev) { bModePhoto  = false; bShowLabels = false; bModeCurves = true ; }
            else       { bModePhoto  = true ; bShowLabels = false; bModeCurves = false; }
        }
        else
        if (slide == 1.0)
        {
            if (bPrev) { bModePhoto  = true ; bShowLabels = false; bModeCurves = false; }
            else       { bModePhoto  = false; bShowLabels = true ; bModeCurves = false; }
        }
        else
        {
            if (bPrev) { bModePhoto  = false; bShowLabels = true ; bModeCurves = false; }
            else       { bModePhoto  = false; bShowLabels = false; bModeCurves = true ; }
        }
    }

    float typeY      = NUM_TYPES*q.y;
    float mul1       = floor(     typeY);
    float mul2       = floor(2. * typeY);
    float mul4       = floor(4. * typeY);
    bool  bTopHalf   = mod( mul1, 2.0 ) >= 1.0;
    bool  bTopEighth = mod( mul4, 8.0 ) >= 7.0;
    bool  bBotEighth = mod( mul4, 8.0 ) <  1.0;

    float CYCLE_TIME = 12.0; // seconds
    vec3  tex  = texture( iChannel0, q ).rgb;
    float mono = sRGBToPerceivedLightness( tex ); // (tex.r + tex.g + tex.b)/3.0;

    float k    = q.x;
    vec3  col;
    vec3  jet  = Map(k, type);          // Color Mapping
    vec3  lin  = vec3( sRGBToPerceivedLightness( jet ) );
    vec3  rrr  = vec3( jet.r, 0.0  , 0.0   );
    vec3  ggg  = vec3( 0.0  , jet.g, 0.0   );
    vec3  bbb  = vec3( 0.0  , 0.0  , jet.b );
    float time = mod( iTime, CYCLE_TIME ) / CYCLE_TIME;
    vec3  gry  = vec3(k);               // linear grayscale
    vec3  gray = bBotEighth ? gry : lin;
    vec3  rgb  = hue2rgb(k);            // primary color gradients for reference
    vec3  hue  = bTopEighth ? rgb : jet;
    vec3  anim = bBotEighth ? rgb :
                 bLeftClick ? Map( mouse.x, type ) : Map(time, type );

    float pad     = 6.0;
    float width   = gvFontSize.x * (12. + pad);
    float center  = (iResolution.x - width) * 0.5;
    float safeTop = (iResolution.y - 8.);
    float safeBot = (gvFontSize.y + 2.);
#if FULL_STATUS
    #define STATUS_W (gvFontSize.x * 20.)
#else
    #define STATUS_W (gvFontSize.x * 3.0)
#endif

    if (bModePhoto)
    {
        // Easter Egg: Squeeze in selecting a 13th type -- the original color image
        // when the user hovers over the status bar.
        if ((iMouse.y < safeBot) && (iMouse.x > 0.) && (iMouse.x < STATUS_W))
            type = NUM_TYPES + 1.0;

        if (type < NUM_TYPES)
            col = Map(mono, type);
        else
            col = tex; // Original image
    }
    else
    {
        if (type >= NUM_TYPES)
            type  = NUM_TYPES;

        /**/ if (q.y < 1.0 / NUM_BARS) { col =anim; if (bShowLabels) col = Labels( col, p, 1.0, -360. ); }
        else if (q.y < 2.0 / NUM_BARS) { col =gray; if (bShowLabels) col = Labels( col, p, 2.0, +360. ); }
        else if (q.y < 3.0 / NUM_BARS) { col = bbb; if (bShowLabels) col = Labels( col, p, 3.0,  240. ); }
        else if (q.y < 4.0 / NUM_BARS) { col = ggg; if (bShowLabels) col = Labels( col, p, 4.0,  120. ); }
        else if (q.y < 5.0 / NUM_BARS) { col = rrr; if (bShowLabels) col = Labels( col, p, 5.0,    0. ); }
        else if (q.y < 6.0 / NUM_BARS) { col = hue; if (bShowLabels) col = Labels( col, p, 6.0, +360. ); }
    }

    float MONITOR_GAMMA = 2.2;
    vec3 gamma = vec3( pow( col, vec3(1.0 / MONITOR_GAMMA) ) ); // gamma correct
    vec3 final = (iMouse.z < 0.5) ? gamma : col;

    if ((p.y <= safeBot) && (p.x < STATUS_W)) // Status bar
    {
        vec3 colorFG = BLACK;
        vec3 colorBG = WHITE;
        final = colorBG; // Alt. 50% transparency: mix( col, colorBG, 0.5 );
#if FONT
        float left = 0.0;
        float k, len;

        gvPrintCharXY.xy = vec2( left + gvFontSize.x, 1.0 ); // pixels
        float reverse = NUM_TYPES - type;
#if FULL_STATUS
        if (type < NUM_TYPES)
            final = Print( final, colorFG, p, text3(len, 65.0 + type, 32.0, 61.0) );
        CharAlpha( p, 0.0 );
        final = Status( type, final, colorFG, p );
#else
        if (type < NUM_TYPES)
            final = Print( final, colorFG, p, text3(len, 65.0 + type, 0.0, 0.0) );
#endif
#endif
    }
    
    if (!bModePhoto)
    {
        if (bModeCurves) // Visualize Color Curves
        {
            vec3  dist3     = vec3(q.y) - jet;
            float thickness = 0.5*gvFontSize.x / iResolution.y;
            vec3  t3        = smoothstep(vec3(0.), vec3(thickness), abs(dist3));
            final = mix( WHITE, final*0.25, t3 );

            // Visualize perceived lightness
            float whiteDist = q.y - lin.y;
            float t1        = smoothstep(0., thickness, abs(whiteDist));
            final = mix( 0.5*WHITE, final, t1 );
        }
        else // Metronome Color "sweep"
        {
#if METRONOME
            #define METRONOME_THICKNESS 1.
            float s = (bLeftClick) ? iMouse.x : floor(time*iResolution.x);
            if ((p.x >= (s - METRONOME_THICKNESS)) && (p.x <= (s + METRONOME_THICKNESS)))
            {
                /**/ if (q.y <  1.0 / NUM_BARS) final = WHITE;
                else if (q.y >= 5.0 / NUM_BARS) final = BLACK;       
                else                            final = Map(s/iResolution.x, type );
            }
#endif
        }
    }

    if (bLeftClick)
    {
#if SEPARATOR
        float L0    = 0.0;
        float R0    = (gvFontSize.x * 3.0);
        float L1    = iResolution.x - R0;
        float R1    = iResolution.x;
        float minX = (bModePhoto) ? L0 : (bModeCurves) ? L1 : R0;
        float maxX = (bModePhoto) ? R0 : (bModeCurves) ? R1 : L1;

        float h = 1.5;
        if ((p.y > h) && (p.x >= minX) && (p.x <= maxX))
        {
           #define STIPPLE   6.0
           #define ANTSPEED 12.0 // "marching ants" speed in seconds

            // stipple marching ants for row borders
           float m = iResolution.y / NUM_TYPES;
           float ant = ANTSPEED*iTime + mod(iTime,ANTSPEED);
           if (mod( p.y, m ) < h)
           {
               float r = mod( p.x - ant, STIPPLE );
               final = BLACK;
               if (r >= (0.5*STIPPLE))
                   final = WHITE;
            }

            // stipple marching ants for column borders
            float n = iResolution.x / NUM_COLS;
            if (floor(mod( p.x, n)) == 0.0)
            {
               float r = mod( p.y + ant, STIPPLE );
               final = BLACK;
               if (r >= (0.5*STIPPLE))
                   final = WHITE;
               // final = WHITE; vec3(0,0.5,1);
            }
        }
#endif

        if (p.y <= gvFontSize.y + 1.)
        {
#if FONT && DEBUG
            vec2 c = vec2(center + 0.0*gvFontSize.x,0.0);
            k = PrintValue( p, c, gvFontSize, iResolution.x, 0.0, 0.0 );
            final = mix( final, BLACK, k );

            c = vec2(center + 8.0*gvFontSize.x,0.0);
            k = PrintValue( p, c, gvFontSize, iResolution.y, 0.0, 0.0 );
            final = mix( final, BLACK, k );

            c = vec2(iResolution.x - 16.0*gvFontSize.x,0.0);
            k = PrintValue( p, c, gvFontSize, iMouse.x, 0.0, 0.0 );
            final = mix( final, 1.-final, k ); // vec3(1,0,0)

            c = vec2(iResolution.x - 8.0*gvFontSize.x,0.0);
            k = PrintValue( p, c, gvFontSize, iMouse.y, 0.0, 0.0 );
            final = mix( final, 1.-final, k ); //  vec3(0,1,0)
#endif
        }
    }

    fragColor  = vec4(final,1.0);
}
