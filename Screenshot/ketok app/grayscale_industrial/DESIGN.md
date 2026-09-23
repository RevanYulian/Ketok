---
name: Grayscale Industrial
colors:
  surface: '#f8f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f6'
  surface-container: '#edeef0'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e2e4'
  on-surface: '#191c1e'
  on-surface-variant: '#45474c'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f3'
  outline: '#76777c'
  outline-variant: '#c6c6cc'
  surface-tint: '#585e6c'
  primary: '#030813'
  on-primary: '#ffffff'
  primary-container: '#1a202c'
  on-primary-container: '#828796'
  inverse-primary: '#c1c6d7'
  secondary: '#5b5f62'
  on-secondary: '#ffffff'
  secondary-container: '#dde0e4'
  on-secondary-container: '#5f6367'
  tertiary: '#000817'
  on-tertiary: '#ffffff'
  tertiary-container: '#152031'
  on-tertiary-container: '#7d889c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde2f3'
  primary-fixed-dim: '#c1c6d7'
  on-primary-fixed: '#161c27'
  on-primary-fixed-variant: '#414754'
  secondary-fixed: '#e0e3e7'
  secondary-fixed-dim: '#c3c7cb'
  on-secondary-fixed: '#181c1f'
  on-secondary-fixed-variant: '#43474b'
  tertiary-fixed: '#d8e3fa'
  tertiary-fixed-dim: '#bcc7dd'
  on-tertiary-fixed: '#111c2c'
  on-tertiary-fixed-variant: '#3c475a'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e1e2e4'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: '0'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: '0'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: '0'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: '0'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system embodies a high-end, industrial aesthetic tailored for a premium service marketplace. It prioritizes clarity, structural integrity, and architectural precision. The visual language is rooted in **Minimalism** with a focus on "Soft Concrete" textures and "Deep Jet" accents, creating a professional environment that feels both sturdy and sophisticated.

The target audience consists of discerning users who value efficiency and high-quality craftsmanship. The emotional response should be one of calm reliability and quiet luxury. Visual depth is achieved through material layering rather than decorative effects, ensuring that the service providers and content remain the focal point.

## Colors
The palette is strictly monochromatic and utilitarian, mimicking industrial materials like polished concrete and forged steel.

- **Surface (#F5F6F8):** Used for the primary app canvas to provide a clean, expansive feel.
- **Secondary (#E2E5E9):** Employed for container backgrounds, divider lines, and subtle structural elements.
- **Structure (#4A5568):** Used for icons, borders, and UI elements that require visual weight without the finality of black.
- **Primary/CTA (#1A202C):** Reserved exclusively for high-priority actions and brand-critical touchpoints.
- **Text Hierarchy:** Text Primary (#2D3748) ensures high legibility for headings, while Text Secondary (#718096) is used for metadata and helper text to maintain a clean visual hierarchy.

## Typography
This design system utilizes a dual-font approach to balance character with utility. **Manrope** is used for headlines to provide a modern, refined geometric feel. **Inter** is used for body copy and labels for its exceptional legibility and systematic, neutral tone.

Tighten letter-spacing on larger headlines to enhance the "industrial" feel. Use the `label-md` style (uppercase with tracking) for section headers and small category tags to create a blueprint-like aesthetic.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy on desktop and a **Fluid Grid** on mobile. A strict 8px baseline grid governs all spatial relationships.

- **Desktop:** 12-column grid with a 1200px max-width, 24px gutters, and 48px outside margins.
- **Mobile:** 4-column fluid grid with 16px gutters and 16px margins.
- **Rhythm:** Use generous whitespace between sections (64px+) to evoke a gallery-like, premium atmosphere. Elements within cards should use tight, 16px or 24px padding to maintain a structured, compact industrial look.

## Elevation & Depth
Elevation is conveyed through **Tonal Layers** and **Low-Contrast Outlines**. Avoid heavy drop shadows to maintain the minimalist aesthetic.

- **Level 0 (Base):** Background color #F5F6F8.
- **Level 1 (Cards/Containers):** Background color #FFFFFF with a 1px solid border of #E2E5E9.
- **Interactive State:** When an element is hovered or active, use a subtle 4px blur shadow with 5% opacity tinted with #1A202C to suggest a slight lift.
- **Overlays:** Modals use a solid 1px border (#4A5568) to define their boundaries against the dimming backdrop.

## Shapes
The shape language is **Soft (0.25rem)**. This slight rounding takes the edge off the industrial aesthetic, preventing it from feeling too aggressive or "brutalist," while maintaining a sharp, precision-engineered look. 

Buttons and input fields should strictly adhere to the 4px (0.25rem) radius. Large containers or image blocks can scale up to `rounded-lg` (8px) if they contain complex content, but never exceed this to preserve the architectural integrity.

## Components
- **Buttons:** Primary buttons are solid #1A202C with #FFFFFF text. Secondary buttons are outlined with #4A5568. Use a "square-ish" aspect ratio for a more technical feel.
- **Input Fields:** Use a 1px border (#E2E5E9). On focus, the border changes to #1A202C. Labels should use the `label-md` typographic style, placed above the field.
- **Chips/Tags:** Use the Secondary color (#E2E5E9) for the background with Text Secondary (#718096) for the label. No icons in chips to maintain minimalism.
- **Cards:** Cards are white with a 1px #E2E5E9 border. Use "Internal Gutters" of 24px for content inside cards.
- **Lists:** Service listings should be separated by 1px horizontal rules (#E2E5E9) rather than individual cards to create a streamlined, efficient browsing experience.
- **Checkboxes/Radios:** Square-off checkboxes to match the 4px roundedness. Use #1A202C for the checked state to provide high-contrast feedback.