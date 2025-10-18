# Tenant Management - Payment History Modal Enhancement

## Summary
Replaced the "View History" link that redirected to a separate page with a modal popup that displays the tenant's complete payment history inline, improving user experience and workflow efficiency.

## Changes Made

### 1. AJAX Endpoint for Payment History

**Added PHP handler** (Lines 11-30):
```php
// Fetch payment history for AJAX request
if (isset($_GET['ajax']) && $_GET['ajax'] === 'payment_history' && isset($_GET['tenant_id'])) {
    $tenant_id = (int)$_GET['tenant_id'];
    
    $stmt = $pdo->prepare("
        SELECT 
            p.payment_id,
            p.amount,
            p.payment_date,
            p.due_date,
            p.status,
            p.payment_method,
            p.reference_number,
            p.created_at
        FROM payments p
        JOIN tenants t ON p.booking_id = t.booking_id
        WHERE t.tenant_id = ? AND t.dorm_id IN (SELECT dorm_id FROM dormitories WHERE owner_id = ?)
        ORDER BY p.created_at DESC
    ");
    $stmt->execute([$tenant_id, $owner_id]);
    $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    header('Content-Type: application/json');
    echo json_encode($payments);
    exit();
}
```

**Features:**
- Returns JSON data for AJAX requests
- Filters payments by tenant_id
- Ensures owner only sees their own tenants' payments
- Orders by most recent first
- Includes all payment details

### 2. Updated Action Button

**Before:**
```html
<a href="/modules/owner/owner_payments.php?tenant_id=<?= $tenant['tenant_id'] ?>" 
   class="btn btn-outline">
    <i class="fa fa-history"></i> View History
</a>
```

**After:**
```html
<button onclick="openPaymentHistoryModal(<?= $tenant['tenant_id'] ?>, '<?= htmlspecialchars($tenant['tenant_name']) ?>')" 
        class="btn btn-outline">
    <i class="fa fa-history"></i> View History
</button>
```

**Benefits:**
- Opens modal instead of navigating away
- Stays on current page
- Faster interaction
- Better UX

### 3. Payment History Modal

**HTML Structure:**
```html
<div id="paymentHistoryModal" class="modal">
  <div class="modal-content" style="max-width: 800px; max-height: 90vh; overflow-y: auto;">
    <div class="modal-header">
      <h2>Payment History - <span id="historyTenantName"></span></h2>
      <button onclick="closeModal('paymentHistoryModal')" class="close-btn">&times;</button>
    </div>
    
    <div id="paymentHistoryContent">
      <!-- Content loaded dynamically via JavaScript -->
    </div>
    
    <button onclick="closeModal('paymentHistoryModal')" class="btn btn-secondary">
      Close
    </button>
  </div>
</div>
```

**Features:**
- Wide modal (800px) for table display
- Scrollable content for long payment histories
- Dynamic content loading
- Loading spinner while fetching data

### 4. Payment Summary Cards

Displays at top of modal:
- **Total Paid**: Sum of all paid payments
- **Pending**: Sum of all pending payments
- **Total Payments**: Count of all payment records

```html
<div class="payment-summary">
  <div class="summary-item">
    <h3>₱XX,XXX.XX</h3>
    <p>Total Paid</p>
  </div>
  <!-- ... more cards -->
</div>
```

### 5. Payment History Table

**Columns:**
- Date (payment date or "Not paid")
- Amount (formatted with currency)
- Due Date
- Status (color-coded badge)
- Payment Method
- Reference Number

**Status Badges:**
- **Paid**: Green badge (#d4edda)
- **Pending**: Yellow badge (#fff3cd)
- **Overdue**: Red badge (#f8d7da)

### 6. JavaScript Functions

#### `openPaymentHistoryModal(tenantId, tenantName)`
```javascript
function openPaymentHistoryModal(tenantId, tenantName) {
    // Set tenant name in modal title
    document.getElementById('historyTenantName').textContent = tenantName;
    
    // Show modal
    document.getElementById('paymentHistoryModal').style.display = 'flex';
    
    // Show loading spinner
    document.getElementById('paymentHistoryContent').innerHTML = `
        <div class="spinner"></div>
        <p>Loading payment history...</p>
    `;
    
    // Fetch data via AJAX
    fetch(`?ajax=payment_history&tenant_id=${tenantId}`)
        .then(response => response.json())
        .then(payments => displayPaymentHistory(payments))
        .catch(error => {
            // Show error message
        });
}
```

#### `displayPaymentHistory(payments)`
```javascript
function displayPaymentHistory(payments) {
    if (payments.length === 0) {
        // Show "No payment history" message
        return;
    }
    
    // Calculate summary statistics
    const totalPaid = payments.filter(p => p.status === 'paid')
                               .reduce((sum, p) => sum + parseFloat(p.amount), 0);
    
    // Build HTML table with summary cards
    // Display in modal
}
```

#### `formatDate(dateString)`
```javascript
function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}
```

### 7. CSS Styling

**Payment History Table:**
```css
.payment-history-table {
    width: 100%;
    border-collapse: collapse;
}

.payment-history-table th {
    background: #f8f9fa;
    padding: 12px;
    text-align: left;
    font-weight: 600;
}

.payment-history-table tr:hover {
    background: #f8f9fa;
}
```

**Status Badges:**
```css
.status-badge {
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

.status-badge.paid { background: #d4edda; color: #155724; }
.status-badge.pending { background: #fff3cd; color: #856404; }
.status-badge.overdue { background: #f8d7da; color: #721c24; }
```

**Loading Spinner:**
```css
.spinner {
    border: 4px solid #f3f3f3;
    border-top: 4px solid #8b5cf6;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
```

**Payment Summary:**
```css
.payment-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 8px;
}
```

## User Experience Flow

### Before:
1. User clicks "View History"
2. **Redirected to separate page**
3. Views payment history
4. Must use back button to return
5. Loses context of current page

### After:
1. User clicks "View History"
2. **Modal opens instantly**
3. Loading spinner appears
4. Payment history loads via AJAX
5. Summary cards show totals
6. Detailed table displays all payments
7. User clicks "Close" or outside modal
8. **Returns to same spot on page**
9. No navigation required

## Features

### 1. Summary Statistics
- **Total Paid**: Sum of all completed payments
- **Pending**: Sum of payments awaiting payment
- **Total Payments**: Count of all payment records

### 2. Detailed Payment Table
- **Payment Date**: When payment was made (or "Not paid")
- **Amount**: Formatted currency (₱XX,XXX.XX)
- **Due Date**: When payment is/was due
- **Status**: Color-coded badge (Paid/Pending/Overdue)
- **Payment Method**: How payment was made
- **Reference Number**: Transaction reference

### 3. Empty State
If no payments exist:
- Friendly icon
- "No Payment History" message
- Explanation text

### 4. Error Handling
If AJAX fails:
- Error icon
- "Error Loading Payment History" message
- Suggestion to try again

### 5. Loading State
While fetching data:
- Animated spinner
- "Loading payment history..." text

## Technical Implementation

### AJAX Request Flow:
```
User clicks "View History"
    ↓
JavaScript: openPaymentHistoryModal()
    ↓
Show modal with loading spinner
    ↓
Fetch: GET ?ajax=payment_history&tenant_id=X
    ↓
PHP: Fetch payments from database
    ↓
PHP: Return JSON response
    ↓
JavaScript: displayPaymentHistory()
    ↓
Build HTML table with data
    ↓
Display in modal
```

### Security:
- Owner verification in SQL query
- Prepared statements prevent SQL injection
- Type casting for tenant_id
- JSON encoding prevents XSS
- Only shows payments for owner's properties

### Performance:
- AJAX call only when needed (on-demand)
- Data fetched only when modal opens
- No unnecessary page loads
- Minimal database queries

## Benefits

### User Experience:
✅ No page navigation required
✅ Instant access to payment history
✅ Stay in context
✅ Faster workflow
✅ Professional modal interface

### Technical:
✅ Modern AJAX implementation
✅ Efficient data loading
✅ Responsive design
✅ Error handling
✅ Loading states

### Business:
✅ Quick access to tenant payment info
✅ Summary statistics at a glance
✅ Detailed payment tracking
✅ Better tenant management

## Data Displayed

For each payment:
- **Payment ID** (internal)
- **Amount** (₱XX,XXX.XX format)
- **Payment Date** (formatted: "Jan 15, 2025")
- **Due Date** (formatted: "Jan 15, 2025")
- **Status** (paid/pending/overdue)
- **Payment Method** (bank_transfer, gcash, cash, etc.)
- **Reference Number** (transaction ID)
- **Created At** (when record was created)

## Modal Specifications

- **Width**: 800px (wider for table)
- **Max Height**: 90vh (90% of viewport height)
- **Overflow**: Scrollable if content exceeds height
- **Backdrop**: Semi-transparent dark overlay
- **Animations**: Smooth fade-in
- **Responsive**: Adapts to mobile screens

## Files Modified

1. `Main/modules/owner/owner_tenants.php`
   - Added AJAX endpoint for payment history
   - Changed "View History" link to button
   - Added Payment History Modal HTML
   - Added CSS styling for table and badges
   - Added JavaScript functions for AJAX and display

## Database Query

```sql
SELECT 
    p.payment_id,
    p.amount,
    p.payment_date,
    p.due_date,
    p.status,
    p.payment_method,
    p.reference_number,
    p.created_at
FROM payments p
JOIN tenants t ON p.booking_id = t.booking_id
WHERE t.tenant_id = ? 
  AND t.dorm_id IN (SELECT dorm_id FROM dormitories WHERE owner_id = ?)
ORDER BY p.created_at DESC
```

**Ensures:**
- Only payments for specified tenant
- Only tenants from owner's properties
- Ordered by most recent first

---
**Date:** October 18, 2025
**Status:** ✅ Complete
**Enhancement:** Modal-based payment history instead of separate page navigation
**Technology:** AJAX, JSON, JavaScript, PHP, Modal UI
