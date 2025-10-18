# 📊 CozyDorm System Architecture - Updated

## 🗄️ Database Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         COZYDORMS DATABASE v2.0                         │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│    USERS     │         │ DORMITORIES  │         │    ROOMS     │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ user_id (PK) │◄───────┤ owner_id (FK)│         │ room_id (PK) │
│ email        │         │ dorm_id (PK) │◄───────┤ dorm_id (FK) │
│ name         │         │ name         │         │ room_type    │
│ role         │         │ address      │         │ capacity     │
│ phone        │         │ latitude ✨  │         │ price        │
│ password     │         │ longitude ✨ │         │ status       │
└──────────────┘         │ cover_image  │         └──────────────┘
                         │ features     │                │
                         │ verified     │                │
                         └──────────────┘                │
                                │                        │
                                │                        │
                         ┌──────────────┐               │
                         │ DORM_IMAGES ✨│              │
                         ├──────────────┤               │
                         │ id (PK)      │               │
                         │ dorm_id (FK) │───────────────┘
                         │ image_path   │
                         │ is_cover     │
                         │ display_order│
                         └──────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                        BOOKING & PAYMENT FLOW                            │
└──────────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   BOOKINGS   │         │  PAYMENTS ✨ │         │  TENANTS ✨  │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ booking_id PK│◄───────┤ booking_id FK│         │ tenant_id PK │
│ room_id (FK) │         │ payment_id PK│         │ booking_id FK│
│ student_id FK│         │ student_id FK│         │ student_id FK│
│ start_date   │         │ amount       │         │ dorm_id (FK) │
│ end_date     │         │ payment_type ✨        │ room_id (FK) │
│ status ✨    │         │   -downpayment│        │ status ✨    │
│ check_in ✨  │         │   -monthly    │        │ check_in ✨  │
│ check_out ✨ │         │   -utility    │        │ check_out ✨ │
│ booking_ref ✨│        │   -deposit    │        │ total_paid   │
└──────────────┘         │   -other      │        │ outstanding  │
       │                 │ status ✨     │        └──────────────┘
       │                 │   -pending    │               │
       │                 │   -submitted  │               │
       │                 │   -processing │               │
       │                 │   -paid       │               │
       │                 │   -verified ✨│               │
       │                 │   -rejected   │               │
       │                 │   -expired    │               │
       │                 │ verified_by ✨│               │
       │                 │ verified_at ✨│               │
       │                 │ payment_method✨              │
       │                 │ reference_num✨│               │
       │                 └──────────────┘               │
       │                        │                       │
       └────────────────────────┴───────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                         SUPPORTING TABLES                                │
└──────────────────────────────────────────────────────────────────────────┘

┌────────────────────┐    ┌──────────────────────┐    ┌──────────────┐
│ PAYMENT_SCHEDULES ✨│   │ USER_PREFERENCES ✨  │    │  MESSAGES    │
├────────────────────┤    ├──────────────────────┤    ├──────────────┤
│ schedule_id (PK)   │    │ id (PK)              │    │ message_id PK│
│ tenant_id (FK)     │    │ user_id (FK) UNIQUE  │    │ sender_id FK │
│ booking_id (FK)    │    │ notification_email   │    │ receiver_id FK│
│ payment_type       │    │ notification_sms     │    │ dorm_id (FK) │
│ amount             │    │ notification_push    │    │ body         │
│ due_date           │    │ notification_payment │    │ created_at   │
│ status             │    │ notification_booking │    │ read_at      │
│ payment_id (FK)    │    │ notification_messages│    └──────────────┘
└────────────────────┘    │ privacy_profile      │
                          │ privacy_show_phone   │
                          │ language             │
                          │ timezone             │
                          └──────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                           DATABASE VIEWS                                 │
└──────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐   ┌──────────────────┐   ┌────────────────────┐
│ view_active_tenants │   │ view_owner_stats │   │ view_tenant_       │
│                     │   │                  │   │    payments        │
│ • Tenant details    │   │ • Total dorms    │   │                    │
│ • Student info      │   │ • Total rooms    │   │ • Payment summary  │
│ • Dorm & room       │   │ • Active tenants │   │ • Total paid       │
│ • Check-in/out      │   │ • Pending books  │   │ • Pending amount   │
│ • Days remaining    │   │ • Monthly revenue│   │ • Last payment     │
│ • Payment status    │   │ • Pending payment│   │ • Outstanding      │
└─────────────────────┘   └──────────────────┘   └────────────────────┘

```

## 🔄 Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    STUDENT TO TENANT WORKFLOW                           │
└─────────────────────────────────────────────────────────────────────────┘

    STUDENT                  SYSTEM                    OWNER
       │                        │                         │
       │  1. Submit Booking     │                         │
       ├───────────────────────►│                         │
       │    status: pending     │  Email Notification     │
       │    booking_ref: BK001  ├────────────────────────►│
       │                        │                         │
       │                        │  2. Review & Approve    │
       │                        │◄────────────────────────┤
       │  Approval Email        │                         │
       │◄───────────────────────┤  TRIGGER FIRES:         │
       │                        │  • booking: approved    │
       │                        │  • tenant: created ✨   │
       │                        │    status: active       │
       │                        │                         │
       │  3. Upload Downpayment │                         │
       │  Receipt               │                         │
       ├───────────────────────►│                         │
       │    type: downpayment ✨│  Payment Notification   │
       │    status: submitted   ├────────────────────────►│
       │                        │                         │
       │                        │  4. Verify Payment      │
       │                        │◄────────────────────────┤
       │  Payment Confirmed     │  TRIGGER FIRES:         │
       │◄───────────────────────┤  • payment: verified ✨ │
       │                        │  • tenant.total_paid    │
       │                        │    updated ✨           │
       │                        │                         │
       │  5. Move-In Date       │                         │
       │  Arrives               │                         │
       ├───────────────────────►│                         │
       │    booking: active ✨  │  Check-in confirmed     │
       │    check_in_date set   ├────────────────────────►│
       │                        │                         │
       │                        │                         │
       │  ⏱️ MONTHLY CYCLE      │                         │
       │                        │                         │
       │  6. Monthly Payment Due│                         │
       │◄───────────────────────┤                         │
       │    type: monthly ✨    │                         │
       │    status: pending     │                         │
       │                        │                         │
       │  7. Upload Receipt     │                         │
       ├───────────────────────►│  Payment Notification   │
       │    status: submitted   ├────────────────────────►│
       │                        │                         │
       │                        │  8. Verify Payment      │
       │                        │◄────────────────────────┤
       │  Payment Confirmed     │  TRIGGER: update paid   │
       │◄───────────────────────┤                         │
       │                        │                         │
       │                        │                         │
       │  9. Move-Out Date      │                         │
       │  Arrives               │                         │
       ├───────────────────────►│                         │
       │                        │  TRIGGER FIRES:         │
       │  Checkout Confirmed    │  • booking: completed ✨│
       │◄───────────────────────┤  • tenant: completed ✨ │
       │    Final Summary       │  • check_out_date set   │
       │    Total Paid: ₱XX     │                         │
       │                        │  Checkout Notification  │
       │                        ├────────────────────────►│
       │                        │                         │
       ▼                        ▼                         ▼

```

## 🎯 Payment Type Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PAYMENT TYPES USAGE                             │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  DOWNPAYMENT ✨  │  Initial payment to secure booking
├──────────────────┤
│ When: Before     │  Usually includes:
│ move-in          │  • First month rent
│ Amount: 1-2x rent│  • Security deposit
│ + deposit        │  • Reservation fee
│ Required: YES    │
│ Status: pending  │  Flow: pending → submitted → verified
│  → submitted     │
│  → verified      │  REQUIREMENT: Must be paid and verified
└──────────────────┘  before student becomes active tenant

┌──────────────────┐
│   MONTHLY ✨     │  Regular rent payment
├──────────────────┤
│ When: Monthly    │  Recurring every month
│ Amount: Fixed    │  Due on same date each month
│ Required: YES    │  (e.g., 1st of month)
│ Status: pending  │
│  → submitted     │  Flow: pending → submitted → paid
│  → paid          │
└──────────────────┘  Multiple instances per tenancy

┌──────────────────┐
│   UTILITY ✨     │  Bills for consumption
├──────────────────┤
│ When: Monthly    │  Can vary month-to-month
│ Amount: Variable │  Based on actual usage
│ Required: Optional│ • Electricity
│ Status: pending  │  • Water
│  → submitted     │  • Internet
│  → paid          │
└──────────────────┘  Flow: pending → submitted → paid

┌──────────────────┐
│   DEPOSIT ✨     │  Security/Damage deposit
├──────────────────┤
│ When: Before     │  Refundable at checkout
│ move-in          │  (if no damages)
│ Amount: 1x rent  │
│ Required: Optional│ Can be part of downpayment
│ Status: pending  │  or separate payment
│  → submitted     │
│  → paid          │  Refunded: On move-out
└──────────────────┘

┌──────────────────┐
│    OTHER ✨      │  Miscellaneous fees
├──────────────────┤
│ When: As needed  │  Examples:
│ Amount: Variable │  • Repair costs
│ Required: NO     │  • Maintenance fees
│ Status: pending  │  • Extra services
│  → submitted     │  • Fines/penalties
│  → paid          │
└──────────────────┘  Flow: pending → submitted → paid

```

## 🏢 Tenant Management Screen Layout

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🏠 Tenant Management                                     [Owner View]   │
│  Track and manage your current and past tenants                         │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│      15      │  │       8      │  │  ₱125,000.00 │  │  ₱15,000.00  │
│ Current      │  │ Past         │  │ Total Revenue│  │ Pending      │
│ Tenants      │  │ Tenants      │  │ (Current)    │  │ Payments     │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  [Current Tenants (15)]  [Past Tenants (8)]                             │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  🔍 Search by name, dorm, or room type...                               │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  JUAN DELA CRUZ                                          [Active ✅]     │
│  Sunshine Dormitory • Single Room                                       │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │ Email        │ │ Phone        │ │ Check-in     │ │ Expected     │  │
│  │ juan@email   │ │ 09XX-XXX-XXX │ │ Jan 15, 2025 │ │ Jul 15, 2025 │  │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘  │
│  ┌──────────────┐ ┌──────────────┐                                     │
│  │ Total Paid   │ │ Payments     │                                     │
│  │ ₱12,500.00   │ │ 3 paid       │                                     │
│  │              │ │ 1 pending    │                                     │
│  └──────────────┘ └──────────────┘                                     │
│  [💬 Message]  [💳 View Payments]  [🏠 View Dorm]                      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  MARIA SANTOS                                         [Warning ⚠️ 15d]  │
│  Blue Haven Dormitory • Shared Room                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │ Email        │ │ Phone        │ │ Check-in     │ │ Expected     │  │
│  │ maria@email  │ │ 09XX-XXX-XXX │ │ Feb 1, 2025  │ │ Nov 1, 2025  │  │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘  │
│  ┌──────────────┐ ┌──────────────┐                                     │
│  │ Total Paid   │ │ Payments     │                                     │
│  │ ₱18,000.00   │ │ 5 paid       │                                     │
│  │              │ │ 0 pending    │                                     │
│  └──────────────┘ └──────────────┘                                     │
│  [💬 Message]  [💳 View Payments]  [🏠 View Dorm]                      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  PEDRO GARCIA                                           [Overdue 🔴]    │
│  Evergreen Dorms • Double Room                                          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  │ Email        │ │ Phone        │ │ Check-in     │ │ Expected     │  │
│  │ pedro@email  │ │ 09XX-XXX-XXX │ │ Mar 1, 2025  │ │ Sep 1, 2025  │  │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘  │
│  ┌──────────────┐ ┌──────────────┐                                     │
│  │ Total Paid   │ │ Payments     │                                     │
│  │ ₱8,500.00    │ │ 2 paid       │                                     │
│  │              │ │ 2 pending ⚠️ │                                     │
│  └──────────────┘ └──────────────┘                                     │
│  [💬 Message]  [💳 View Payments]  [🏠 View Dorm]                      │
└─────────────────────────────────────────────────────────────────────────┘
```

## ✨ Legend

```
✨ = New Feature Added
🔴 = High Priority
🟡 = Medium Priority
🟢 = Low Priority
✅ = Completed
⚠️ = Warning/Attention Required
```

---

**Created:** October 18, 2025  
**Version:** 2.0  
**Status:** IMPLEMENTED & READY FOR DEPLOYMENT
