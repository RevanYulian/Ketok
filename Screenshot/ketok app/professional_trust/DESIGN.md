---
name: Ketok Modern
colors:
  surface: '#f8f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f6'
  surface-container: '#f3f4f6'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e2e4'
  on-surface: '#191c1e'
  on-surface-variant: '#45474c'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f3'
  outline: '#76777c'
  outline-variant: '#e2e5e9'
  surface-tint: '#585e6c'
  primary: '#030813'
  on-primary: '#ffffff'
  primary-container: '#1a202c'
  on-primary-container: '#828796'
  inverse-primary: '#c1c6d7'
  secondary: '#545f72'
  on-secondary: '#ffffff'
  secondary-container: '#d5e0f7'
  on-secondary-container: '#586377'
  tertiary: '#000915'
  on-tertiary: '#ffffff'
  tertiary-container: '#13212f'
  on-tertiary-container: '#7b899a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde2f3'
  primary-fixed-dim: '#c1c6d7'
  on-primary-fixed: '#161c27'
  on-primary-fixed-variant: '#414754'
  secondary-fixed: '#d8e3fa'
  secondary-fixed-dim: '#bcc7dd'
  on-secondary-fixed: '#111c2c'
  on-secondary-fixed-variant: '#3c475a'
  tertiary-fixed: '#d6e4f7'
  tertiary-fixed-dim: '#bac8da'
  on-tertiary-fixed: '#0f1d2a'
  on-tertiary-fixed-variant: '#3b4857'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e1e2e4'
  error-red: '#c53030'
  google-blue: '#4285F4'
  success-green: '#34A853'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  xs: 4px
  base: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  margin-desktop: 48px
  gutter: 24px
---

## Brand & Style

**Ketok** embodies a "Modern Corporate" aesthetic that balances professional reliability with approachable warmth. The brand identity is built on a foundation of structural clarity, using a monochrome-leaning palette punctuated by deep charcoal and soft slate tones. 

The design style is a hybrid of **Minimalism** and **Tactile Modernism**. It avoids the sterility of pure flat design by incorporating subtle depth through soft shadows and intentional radius variations. The emotional response should be one of "Safe Efficiency"—a system that feels as dependable as a physical door but as fluid as a modern SaaS platform.

## Colors

The palette is rooted in high-contrast utility. 
- **Primary (#1a202c):** A deep charcoal used for core actions and critical brand elements, providing a strong anchor for the UI.
- **Secondary (#4a5568):** A muted slate used for labels, icons, and supporting text to maintain hierarchy without competing with the primary actions.
- **Backgrounds:** Utilizes a tiered grayscale system. The base background is a cool off-white (`#f5f6f8`), while containers use pure white to pop against the subtle gray foundations.
- **Accents:** Functional colors (Error, Social Brands) are used sparingly and maintain high saturation to ensure immediate recognition.

## Typography

The system uses **Manrope** exclusively to project a modern, geometric, yet highly legible feel. 
- **Headlines:** Feature tight letter-spacing and heavy weights to create a commanding presence.
- **Labels:** Utilize increased letter-spacing in uppercase or semi-bold variants to differentiate metadata from body content.
- **Hierarchy:** Strict adherence to the 1.2x - 1.5x line-height ratio ensures optimal readability for both Indonesian and English character sets.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a maximum content width of 400px for mobile-first views, expanding to a structured 12-column grid on desktop.

- **Vertical Rhythm:** Built on an 8px base unit. Gaps between form fields use `lg` (24px), while internal element padding (like labels to inputs) uses `xs` (4px).
- **Margins:** A standard 16px gutter on mobile ensures content doesn't hit the bezel, while desktop layouts transition to a generous 48px margin to emphasize the "Minimalist" brand style.
- **Sectioning:** Large vertical spacers (`xl` or 32px) are used to separate logical blocks (e.g., Header vs. Form vs. Social).

## Elevation & Depth

Ketok uses **Tonal Layering** combined with **Ambient Shadows** to define hierarchy.

- **Level 0 (Background):** Surface color `#f5f6f8`.
- **Level 1 (Cards/Inputs):** Pure white `#ffffff` with a `shadow-sm` (subtle 1-2px blur) to indicate interactivity.
- **Level 2 (Primary Buttons/Active States):** Elevated with a `shadow-md` to signify the most important action on the screen.
- **The Header Gradient:** A unique "inverted depth" effect is used at the top of screens, transitioning from a low-container gray to transparent, visually "anchoring" the brand avatar.

## Shapes

The shape language is "Mixed Geometric." 
- **Standard Elements:** Buttons and Inputs use a soft `0.25rem` (4px) radius for a disciplined, professional look.
- **Special Elements:** High-personality items (Avatar containers, Primary Login buttons) use `rounded-xl` (12px) or even unique `40px` bottom-only radii for the header section to create visual interest and brand distinction.
- **Iconography:** Icons are contained within consistent bounding boxes (e.g., 56px circles or squares) to maintain the grid.

## Components

### Buttons
- **Primary:** High-contrast (`#1a202c` bg, `#ffffff` text), 56px height, `rounded-xl`, with a subtle lift shadow.
- **Tab Buttons:** Integrated into a single bordered container. The active tab uses `surface-variant` color with a distinct border-side to indicate state.
- **Social/Icon Buttons:** Circular (`rounded-full`), 56px diameter, bordered with `outline-variant`, using `surface-container-lowest` as the background.

### Input Fields
- **Standard Input:** 56px height, white background, `outline-variant` border. On focus, the border transitions to the primary charcoal color. Labels are placed externally in `label-sm` weight.

### Cards & Dividers
- **Dividers:** 1px horizontal lines using `outline-variant`, often paired with a centered text label in `label-sm` for "OR" separators.
- **Avatar Container:** A signature element featuring a rotated icon within a square container to inject "Ketok" (knock/door) brand personality.