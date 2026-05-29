---
name: Social Alpha Calendar
colors:
  surface: '#051424'
  surface-dim: '#051424'
  surface-bright: '#2c3a4c'
  surface-container-lowest: '#010f1f'
  surface-container-low: '#0d1c2d'
  surface-container: '#122131'
  surface-container-high: '#1c2b3c'
  surface-container-highest: '#273647'
  on-surface: '#d4e4fa'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#d4e4fa'
  inverse-on-surface: '#233143'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#ffb4aa'
  on-secondary: '#690003'
  secondary-container: '#c5020b'
  on-secondary-container: '#ffd2cc'
  tertiary: '#53e16f'
  on-tertiary: '#003911'
  tertiary-container: '#00a741'
  on-tertiary-container: '#00320e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#ffdad5'
  secondary-fixed-dim: '#ffb4aa'
  on-secondary-fixed: '#410001'
  on-secondary-fixed-variant: '#930005'
  tertiary-fixed: '#72fe88'
  tertiary-fixed-dim: '#53e16f'
  on-tertiary-fixed: '#002107'
  on-tertiary-fixed-variant: '#00531c'
  background: '#051424'
  on-background: '#d4e4fa'
  surface-variant: '#273647'
typography:
  display-bold:
    fontFamily: notoSans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: notoSans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: notoSans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: notoSans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: notoSans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-heavy:
    fontFamily: inter
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 22px
  headline-lg-mobile:
    fontFamily: notoSans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 12px
  margin-mobile: 16px
---

## Brand & Style
The design system balances financial precision with a high-energy, social-first aesthetic tailored for the modern Taiwanese retail investor. It moves away from "boring" banking interfaces toward a **Social/Modern** style that borrows from high-end fintech and social media dashboards. 

The personality is witty and fast-paced, utilizing **Glassmorphism** for data overlays and **High-Contrast** elements for critical market signals. Visuals are designed to be "screenshot-ready"—transforming complex trading schedules into clean, shareable assets that look natural on Instagram or LINE groups. The emotional goal is to reduce "trading anxiety" through clarity while fostering a sense of community through playful, bold UI patterns.

## Colors
This design system defaults to a **Dark (OLED)** mode to reduce eye strain during long market sessions and to make the vibrance of the Taiwanese "Up-Red" and "Down-Green" pop. 

- **Primary Blue:** Used for navigation, active states, and non-directional financial events (e.g., board meetings).
- **Market Directional:** We adhere strictly to the Taiwan market standard where **Red (#FF3B30)** signifies growth/bullishness and **Green (#34C759)** signifies decline/bearishness.
- **Semantic Feedback:** Separate from market trends, we use "Hit Green" and "Miss Red" for success/failure states in user actions or prediction outcomes.
- **Meme Mode:** High-contrast variants of these colors should be used with thicker borders and exaggerated shadows to lean into a playful, aggressive visual style.

## Typography
We utilize **Noto Sans TC** as the primary typeface to ensure maximum legibility for Traditional Chinese characters, paired with **Inter** for numerical financial data. 

- **Hierarchy:** Use `display-bold` for "Hero" numbers (e.g., daily profit/loss) to make them easily readable in screenshots.
- **Data Display:** For stock codes and prices, always use `data-heavy` (Inter) to ensure numbers don't bleed into each other.
- **Weight:** Avoid light weights. The UI should feel substantial and "loud" to match the meme-humorous tone.
- **Alignment:** Financial data should be tabular when possible to allow for quick scanning down a vertical list.

## Layout & Spacing
The system uses a **4px base grid** with a focus on high-density information. 

- **Grid Calendar:** Calendar cells follow a square aspect ratio. Use 1px internal dividers for the "Minimal" theme and 4px gutters for the "Default" theme to create a modern, floating tile look.
- **Margins:** Standard mobile side-margin is 16px. Content should be grouped in containers that span the full width minus margins.
- **Vertical Rhythm:** Use 8px (sm) between related elements (label and value) and 16px (md) between distinct sections/cards.
- **Safe Areas:** Ensure all Bottom Navigation and FAB elements account for the iOS/Android home indicator areas, using a minimum bottom padding of 32px.

## Elevation & Depth
Depth is created through **Tonal Layers** and **Glassmorphism**, specifically for mobile-first interactivity.

- **Base Layer:** Background is pure OLED black (#000000) or very dark gray (#0F172A).
- **Surface Layer:** Cards and containers use a subtle elevation tint (10% white overlay) or a 1px border (#1E293B) to define edges without heavy shadows.
- **Modal Bottom Sheets:** Utilize a backdrop blur (15-20px) to maintain context of the calendar behind the action sheet.
- **Meme Mode Elevation:** In this specific theme, replace soft elevations with **Bold Borders** (2px solid white) and hard drop shadows (4px offset, 0px blur) to mimic a "Neo-Brutalist" or comic-book aesthetic.

## Shapes
The shape language is **Rounded** and friendly, conveying a modern "App Store" feel.

- **Standard Radius:** 16px (rounded-lg) for all main cards, modal sheets, and primary buttons.
- **Chips:** Always use pill-shaped (rounded-xl) for stock tags and selection filters to make them look tappable.
- **Calendar Cells:** Use a smaller 8px (soft) radius to maximize internal space for text and icons.
- **Interactive States:** On press, elements should slightly shrink (scale: 0.98) to provide tactile feedback typical of modern social apps.

## Components
- **Floating Action Button (FAB):** A large, 64px circular button for "Add Event" or "Quick Search." Use a gradient of Primary Blue to differentiate from static UI.
- **Calendar Cells:** Must support "Dot Indicators" for multiple events. If the date is a "Big Day" (e.g., Fed Meeting + TSMC Earnings), the cell background should glow subtly.
- **Stock Chips:** Include the stock trend color as a small leading dot. (e.g., [● 2330 TSMC]).
- **Bottom Navigation:** Use a blur-background (Glassmorphism) with 24px icons. Active state uses a vertical "pill" indicator above or below the icon.
- **Shareable Cards:** A specific component designed with a fixed 9:16 aspect ratio "Save as Image" button. It includes the app branding, a witty meme caption (e.g., "To the Moon!"), and the specific stock data.
- **Input Fields:** Use "Filled" style with a 16px radius. The label should float or sit above the field in `label-caps`.