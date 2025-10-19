# Kutip - Effortless Payment Management

## Overview

Kutip is a streamlined payment management application designed to simplify the process of tracking and recording payments. It offers a user-friendly interface for quickly adding new payment records and viewing a comprehensive history of all transactions. 

## Key Features

- **Add New Payments:** Easily record new payments with details such as payer name, phone number, unit information, payment period, and amount.
- **Previous Payments:** View a chronological list of all past payments, sorted with the most recent transactions first. 
- **Payment Details:** Access detailed information for each payment, including a complete breakdown of the transaction, payer information, and payment period.
- **Modern & Intuitive UI:** The app features a clean and modern design with a professional color palette, ensuring a seamless user experience.

## Design and Style

- **Color Palette:** The app utilizes a professional color scheme with a dark background, vibrant blue accents, and pops of red and green for status indicators. The input fields have a distinct background color to provide a clear visual contrast.
- **Typography:** A clear and legible font is used throughout the app, with a well-defined hierarchy for titles, subtitles, and body text.
- **Layout:** The layout is clean and organized, with a focus on usability and easy navigation. Cards are used to elevate important information and create a sense of depth.

## Current Task: Form Refinement and Automation

The current development effort is focused on refining the "Add New Payment" form and automating the calculation of the amount to pay.

### Plan and Steps

1. **Group Input Fields into Cards:**
   - In `lib/add_payment_page.dart`, the input fields for adding a new payment have been grouped into three distinct sections: "Info," "Period," and "Amount."
   - Each section is encapsulated within its own card to create a more organized and visually appealing layout.
   - A new private method, `_buildSectionCard`, was created to handle the common styling and structure of these cards.

2. **Improve Input Field Contrast:**
   - The background color of the input fields has been changed to provide a clear visual contrast against the card background, improving usability and aesthetics.

3. **Refine Input Fields:**
   - The "Unit" input field has been restricted to accept numbers only.
   - The "Year" input fields have been converted to dropdown menus, defaulting to the current year.

4. **Automate Amount Calculation:**
   - The "Amount to Pay" input field has been replaced with a large text display.
   - The application now automatically calculates the amount to pay based on the selected payment period and the monthly fee set on the dashboard.

5. **Display Monthly Fee:**
   - The monthly fee is now displayed in the "Amount" section of the "Add New Payment" form, providing clear context for the calculated amount to pay.

6. **Correct Balance Display:**
   - The balance display has been corrected to show a green "RM 0.00" when the balance is zero, removing the unnecessary negative sign.
