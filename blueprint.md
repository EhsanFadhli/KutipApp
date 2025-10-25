# Kutip - Effortless Offline Payment Management

## Overview

Kutip is a streamlined, completely offline payment management application designed to simplify the process of tracking and recording payments. It offers a user-friendly interface for quickly adding new payment records, viewing a comprehensive history of all transactions, and tracking all actions taken within the app, all stored locally on the device.

## Key Features

- **App Name:** The app is now branded as "Kutip."
- **Add New Payments:** Easily record new payments with details such as payer name, phone number, unit information, payment period, and amount.
- **Previous Payments:** View a chronological list of all past payments, sorted with the most recent transactions first. 
- **Action Logs:** Access a detailed log of all actions taken within the app, including adding payments, archiving payments, and setting the monthly fee. The log now displays the amount associated with each action in a larger font for better visibility.
- **Payment Details:** Access detailed information for each payment, including a complete breakdown of the transaction, payer information, and payment period.
- **Copy Payment Details:** A new copy icon button has been added to the "Payment Details" view. This allows users to easily copy all relevant payment information to the clipboard with a single tap, formatted for easy sharing. The date range is now formatted as `Nov 2025 - Jan 2026`.
- **Modern & Intuitive UI:** The app features a clean and modern design with a professional color palette, ensuring a seamless user experience.

## Design and Style

- **Color Palette:** The app utilizes a professional color scheme with a dark background, vibrant blue accents, and pops of red and green for status indicators. The input fields have a distinct background color to provide a clear visual contrast.
- **Typography:** A clear and legible font is used throughout the app, with a well-defined hierarchy for titles, subtitles, and body text. The letter spacing of the app title has been adjusted for better readability.
- **Layout:** The layout is clean and organized, with a focus on usability and easy navigation. Cards are used to elevate important information and create a sense of depth.

## Current Task: UI Refinement

The current development effort is focused on refining the user interface.

### Plan and Steps

1.  **Adjust Letter Spacing:**
    -   The letter spacing of the "Kutip" title has been adjusted to improve readability.

2.  **Remove App Bar Icon:**
    -   The icon has been removed from the app bar, leaving only the "Kutip" title.

3.  **Update App Bar:**
    -   The app bar title has been changed from "Dashboard" to "Kutip."
    -   The app bar icon has been changed from `Icons.dashboard_customize` to `Icons.monetization_on`.

4.  **Increase Amount Font Size:**
    -   The font size of the amount in the logs has been increased to make it more prominent.

5.  **Update Log Messages:**
    -   The log message for new payments now includes the amount received.
    -   The log message for archiving all recent payments now includes the total amount archived.
    -   The log message for setting the monthly fee has been updated for consistency.

6.  **Enhance Logs UI:**
    -   The "Logs" page now parses the action string to separate the description from the amount.
    -   The amount is now displayed as a distinct, right-aligned element in each log entry for better readability.

7.  **Correct Date Format Bug:**
    -   The `DateFormat` pattern in `lib/ui/widgets.dart` has been corrected to `"MMMM d, yyyy 'at' h:mm a"` to fix a compilation error and ensure the date is formatted correctly.

8.  **Action Logging and New Logs Page:**
    -   A comprehensive action logging system has been implemented.
    -   A new "Logs" page has been created to display all recorded actions.

9.  **Group Input Fields into Cards:**
    -   The input fields in the "Add New Payment" form have been grouped into organized and visually appealing cards.

10. **Improve Input Field Contrast:**
    -   The background color of the input fields has been changed to provide better visual contrast.

11. **Refine Input Fields:**
    -   Input fields have been refined to ensure data integrity and a better user experience.

12. **Automate Amount Calculation:**
    -   The "Amount to Pay" is now automatically calculated based on the selected payment period and the monthly fee.

13. **Display Monthly Fee:**
    -   The monthly fee is now displayed in the "Add New Payment" form.

14. **Correct Balance Display:**
    -   The balance display now correctly shows "RM 0.00" when the balance is zero.

15. **Archived Payments & Confirmation Dialog:**
    -   A confirmation dialog with a 10-second countdown has been added to the "Cash Handed" action to prevent accidental data archival.

16. **Robust Data Handling & Error Resiliency:**
    -   `try-catch` blocks have been implemented to gracefully handle corrupted or malformed data.

17. **Custom Success Notifications:**
    -   The reusable `showSuccessSnackBar` function now uses a dark green background with white text for improved readability and a more professional appearance.

18. **Animated Success Notifications:**
    -   The success `SnackBar` now includes a fade-in and slide-up animation for a more dynamic and engaging user experience.

19. **Disable "Cash Handed" Button:**
    -   The "Cash Handed" button is now disabled when the total cash collected is zero, preventing accidental or unnecessary actions.

20. **Add Copy to Clipboard:**
    - A new copy icon button has been added to the "Payment Details" view. This allows users to easily copy all relevant payment information to the clipboard with a single tap, formatted for easy sharing.

21. **Refine Copy Format:**
    - The date format in the copied text has been updated to be more readable (e.g., `Bulan Nov 2025 - Jan 2026`).
    - Fixed a bug where the unit number was missing from the copied address.