<?php
session_start();

// If user is already logged in, redirect to their dashboard
if (isset($_SESSION['user'])) {
    $role = $_SESSION['user']['role'] ?? '';
    switch ($role) {
        case 'admin':
            header('Location: /dashboards/admin_dashboard.php');
            exit;
        case 'owner':
            header('Location: /dashboards/owner_dashboard.php');
            exit;
        case 'student':
            header('Location: /dashboards/student_dashboard.php');
            exit;
    }
}

// Get database connection
require_once __DIR__ . '/../config.php';

// Fetch real statistics from database
try {
    // Total students
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE role = 'student'");
    $total_students = $stmt->fetch()['count'] ?? 0;
    
    // Total dorms
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM dorms WHERE status = 'active'");
    $total_dorms = $stmt->fetch()['count'] ?? 0;
    
    // Total owners
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE role = 'owner'");
    $total_owners = $stmt->fetch()['count'] ?? 0;
    
    // Total bookings
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM bookings");
    $total_bookings = $stmt->fetch()['count'] ?? 0;
    
    // Featured dorms (top 3 with images)
    $stmt = $pdo->query("SELECT d.*, u.name as owner_name 
                         FROM dorms d 
                         JOIN users u ON d.user_id = u.user_id 
                         WHERE d.status = 'active' 
                         ORDER BY d.created_at DESC 
                         LIMIT 3");
    $featured_dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Recent testimonials (approved bookings with students)
    $stmt = $pdo->query("SELECT u.name, d.name as dorm_name, b.created_at
                         FROM bookings b
                         JOIN users u ON b.user_id = u.user_id
                         JOIN dorms d ON b.dorm_id = d.dorm_id
                         WHERE b.status = 'approved'
                         ORDER BY b.created_at DESC
                         LIMIT 3");
    $testimonials = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
} catch (Exception $e) {
    // Fallback values if database fails
    $total_students = 150;
    $total_dorms = 25;
    $total_owners = 15;
    $total_bookings = 200;
    $featured_dorms = [];
    $testimonials = [];
}

// Handle login form submission
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    require_once __DIR__ . '/../auth/auth.php';
    
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    $stmt = $pdo->prepare("SELECT user_id, name, email, password, role FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        $_SESSION['user'] = [
            'user_id' => $user['user_id'],
            'name'    => $user['name'],
            'email'   => $user['email'],
            'role'    => $user['role'],
        ];
        redirect_to_dashboard($user['role']);
    } else {
        $error = 'Invalid email or password';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>CozyDorms - Premium Student Housing Management System</title>
  <meta name="description" content="Discover and book student housing with ease. CozyDorms connects students with quality dormitories and landlords with reliable tenants.">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.css"/>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root{
      --primary:#6366f1;
      --primary-dark:#4f46e5;
      --primary-light:#818cf8;
      --secondary:#8b5cf6;
      --accent:#ec4899;
      --success:#10b981;
      --dark:#1e293b;
      --gray-50:#f8fafc;
      --gray-100:#f1f5f9;
      --gray-200:#e2e8f0;
      --gray-600:#475569;
      --gray-700:#334155;
      --gray-900:#0f172a;
      --nav-bg:rgba(255,255,255,0.95);
      --shadow-sm:0 1px 2px 0 rgb(0 0 0 / 0.05);
      --shadow:0 4px 6px -1px rgb(0 0 0 / 0.1);
      --shadow-lg:0 10px 15px -3px rgb(0 0 0 / 0.1);
      --shadow-xl:0 20px 25px -5px rgb(0 0 0 / 0.1);
    }

    *{box-sizing:border-box;margin:0;padding:0;}
    body{
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      color:var(--gray-900);
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      scroll-behavior:smooth;
      line-height:1.6;
      overflow-x:hidden;
    }

    section{min-height:100vh;display:flex;justify-content:center;align-items:center;padding:4rem 1.5rem;position:relative;}
    .container{background:white;padding:3rem;border-radius:24px;box-shadow:var(--shadow-xl);max-width:1200px;width:100%;position:relative;z-index:1;}

    /* Navigation */
    .scroll-nav{
      position:fixed;left:0;right:0;top:0;
      display:flex;justify-content:center;align-items:center;
      background:var(--nav-bg);
      padding:16px 24px;
      backdrop-filter:blur(10px);
      box-shadow:var(--shadow);
      z-index:1200;
      transition:all 0.3s ease;
    }
    .scroll-nav.scrolled{padding:12px 24px;box-shadow:var(--shadow-lg);}
    .nav-inner{display:flex;align-items:center;gap:20px;width:100%;max-width:1200px;justify-content:space-between;}
    .nav-logo{
      font-size:1.5rem;font-weight:800;
      background:linear-gradient(135deg, var(--primary), var(--secondary));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
      display:flex;align-items:center;gap:8px;
    }
    .nav-logo-icon{font-size:1.8rem;}
    .nav-links{display:flex;gap:8px;padding:6px;border-radius:12px;background:var(--gray-100);position:relative;}
    .nav-link{
      padding:10px 20px;border-radius:10px;text-decoration:none;color:var(--gray-600);font-weight:500;
      transition:all .3s ease;position:relative;z-index:2;font-size:0.95rem;
    }
    .nav-link.active{color:var(--gray-900)}
    .nav-link:hover{color:var(--gray-900)}
    .nav-indicator{
      position:absolute;background:white;border-radius:10px;
      transition:left .3s cubic-bezier(.4,0,.2,1), width .3s cubic-bezier(.4,0,.2,1);
      height:calc(100% - 12px);top:6px;box-shadow:var(--shadow-sm);z-index:1;
    }

    /* Buttons */
    .btn{
      display:inline-block;padding:12px 32px;
      background:linear-gradient(135deg, var(--primary), var(--primary-dark));
      color:white;text-decoration:none;border-radius:12px;font-weight:600;
      transition:all .3s ease;cursor:pointer;border:none;font-size:1rem;
      box-shadow:var(--shadow);position:relative;overflow:hidden;
    }
    .btn::before{
      content:'';position:absolute;top:0;left:-100%;width:100%;height:100%;
      background:linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
      transition:left 0.5s;
    }
    .btn:hover::before{left:100%;}
    .btn:hover{transform:translateY(-2px);box-shadow:var(--shadow-lg);}
    .btn:active{transform:translateY(0);box-shadow:var(--shadow);}
    .btn-secondary{background:white;color:var(--primary);border:2px solid var(--primary);}
    .btn-secondary:hover{background:var(--gray-50);}
    .nav-btn{padding:10px 28px;font-size:0.95rem;}

    /* Hero */
    .hero{text-align:center;max-width:900px;padding:2rem 0;}
    .hero-badge{
      display:inline-block;padding:8px 20px;background:var(--gray-100);
      border-radius:50px;font-size:0.85rem;font-weight:600;color:var(--primary);
      margin-bottom:1.5rem;letter-spacing:0.5px;
    }
    .logo{font-size:5rem;margin-bottom:1.5rem;filter:drop-shadow(0 4px 8px rgba(0,0,0,0.1));}
    h1{
      font-size:3.5rem;margin:0.5rem 0;font-weight:800;
      background:linear-gradient(135deg, var(--gray-900), var(--gray-700));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
      line-height:1.2;letter-spacing:-1px;
    }
    .hero p{font-size:1.25rem;color:var(--gray-600);margin:1.5rem auto 2.5rem;max-width:600px;line-height:1.8;}
    .hero-buttons{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;}
    h2{font-size:2.5rem;margin-bottom:1rem;font-weight:700;color:var(--gray-900);letter-spacing:-0.5px;text-align:center;}
    h3{font-size:1.3rem;margin:0.5rem 0;font-weight:600;color:var(--gray-900);}
    p{color:var(--gray-600);line-height:1.8;}
    .section-subtitle{font-size:1.1rem;color:var(--gray-600);max-width:700px;margin:0 auto 3rem;line-height:1.8;text-align:center;}
    .gradient-text{
      background:linear-gradient(135deg, var(--primary), var(--secondary));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
    }
    @keyframes float{0%, 100%{transform:translateY(0);} 50%{transform:translateY(-10px);}}
    .floating{animation:float 3s ease-in-out infinite;}

    /* Stats */
    .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:2rem;margin-top:3rem;}
    .stat-card{text-align:center;padding:2rem;}
    .stat-number{
      font-size:3rem;font-weight:800;
      background:linear-gradient(135deg, var(--primary), var(--secondary));
      -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
      margin-bottom:0.5rem;
    }
    .stat-label{font-size:1rem;color:var(--gray-600);font-weight:500;}

    /* Features */
    .features{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:2rem;margin-top:3rem;}
    .feature-card{
      background:linear-gradient(135deg, var(--gray-50), white);
      padding:2.5rem;border-radius:20px;
      transition:all .4s cubic-bezier(0.4, 0, 0.2, 1);
      border:1px solid var(--gray-200);
      position:relative;overflow:hidden;
    }
    .feature-card::before{
      content:'';position:absolute;top:0;left:0;right:0;height:4px;
      background:linear-gradient(90deg, var(--primary), var(--secondary));
      transform:scaleX(0);transition:transform 0.4s ease;
    }
    .feature-card:hover::before{transform:scaleX(1);}
    .feature-card:hover{transform:translateY(-8px);box-shadow:var(--shadow-xl);border-color:var(--primary-light);}
    .feature-icon{font-size:3.5rem;margin-bottom:1rem;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.1));}
    .feature-card h3{margin-bottom:0.8rem;}
    .feature-card p{font-size:0.95rem;line-height:1.7;}

    /* Featured Dorms */
    .dorms-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:2rem;margin-top:3rem;}
    .dorm-card{
      background:white;border-radius:16px;overflow:hidden;
      box-shadow:var(--shadow);transition:all 0.3s ease;
      border:1px solid var(--gray-200);
    }
    .dorm-card:hover{transform:translateY(-8px);box-shadow:var(--shadow-xl);}
    .dorm-image{
      width:100%;height:200px;background:var(--gray-200);
      background-size:cover;background-position:center;
      position:relative;
    }
    .dorm-badge{
      position:absolute;top:12px;right:12px;
      background:var(--success);color:white;
      padding:6px 12px;border-radius:20px;
      font-size:0.8rem;font-weight:600;
    }
    .dorm-content{padding:1.5rem;}
    .dorm-title{font-size:1.2rem;font-weight:700;color:var(--gray-900);margin-bottom:0.5rem;}
    .dorm-info{display:flex;align-items:center;gap:0.5rem;color:var(--gray-600);font-size:0.9rem;margin-bottom:0.5rem;}
    .dorm-price{font-size:1.5rem;font-weight:800;color:var(--primary);margin-top:1rem;}

    /* Testimonials */
    .testimonials{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:2rem;margin-top:3rem;}
    .testimonial-card{
      background:var(--gray-50);padding:2rem;border-radius:16px;
      border-left:4px solid var(--primary);position:relative;
    }
    .testimonial-quote{font-size:0.95rem;color:var(--gray-700);margin-bottom:1.5rem;line-height:1.8;font-style:italic;}
    .testimonial-author{display:flex;align-items:center;gap:1rem;}
    .testimonial-avatar{
      width:48px;height:48px;border-radius:50%;
      background:linear-gradient(135deg, var(--primary), var(--secondary));
      display:flex;align-items:center;justify-content:center;color:white;font-weight:700;font-size:1.2rem;
    }
    .testimonial-info h4{font-size:0.95rem;color:var(--gray-900);margin-bottom:0.2rem;}
    .testimonial-info p{font-size:0.85rem;color:var(--gray-600);margin:0;}

    /* CTA */
    .cta-section{
      text-align:center;background:linear-gradient(135deg, var(--primary), var(--secondary));
      color:white;border-radius:24px;padding:4rem 2rem;margin-top:3rem;
    }
    .cta-section h2{color:white;-webkit-text-fill-color:white;margin-bottom:1rem;}
    .cta-section p{color:rgba(255,255,255,0.9);font-size:1.1rem;margin-bottom:2rem;}
    .cta-buttons{display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;}

    /* Footer */
    .footer{background:var(--gray-900);color:var(--gray-300);padding:3rem 2rem 1.5rem;margin-top:0;}
    .footer-content{max-width:1200px;margin:0 auto;display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:2rem;}
    .footer-section h4{color:white;margin-bottom:1rem;font-size:1.1rem;}
    .footer-section ul{list-style:none;}
    .footer-section ul li{margin-bottom:0.7rem;}
    .footer-section a{color:var(--gray-400);text-decoration:none;transition:color 0.3s;}
    .footer-section a:hover{color:white;}
    .footer-bottom{
      text-align:center;margin-top:2rem;padding-top:2rem;border-top:1px solid var(--gray-700);
      color:var(--gray-500);font-size:0.9rem;
    }

    /* Modal */
    .modal {
      display: none;position: fixed;z-index: 2000;left: 0;top: 0;width: 100%;height: 100%;
      background-color: rgba(0,0,0,0.6);animation: fadeIn 0.3s;
    }
    @keyframes fadeIn {from { opacity: 0; } to { opacity: 1; }}
    .modal-content {
      background-color: #fff;margin: 5% auto;padding: 0;border-radius: 16px;
      width: 90%;max-width: 420px;box-shadow: 0 8px 30px rgba(0,0,0,0.3);
      animation: slideDown 0.3s;position: relative;
    }
    @keyframes slideDown {
      from {transform: translateY(-50px);opacity: 0;}
      to {transform: translateY(0);opacity: 1;}
    }
    .modal-header {
      padding: 1.5rem 2rem;border-bottom: 1px solid #eee;
      display: flex;justify-content: space-between;align-items: center;
    }
    .modal-header h2 {margin: 0;font-size: 1.5rem;color: #1f1147;}
    .close {
      color: #aaa;font-size: 28px;font-weight: bold;cursor: pointer;
      background: none;border: none;padding: 0;width: 30px;height: 30px;
      display: flex;align-items: center;justify-content: center;
      border-radius: 50%;transition: background 0.2s, color 0.2s;
    }
    .close:hover,.close:focus {background: #f0f0f0;color: #000;}
    .modal-body {padding: 2rem;}
    .modal-body .alert {
      background: #f8d7da;color: #721c24;padding: 0.8rem;
      border-radius: 8px;margin-bottom: 1rem;font-size: 0.9rem;
    }
    .modal-body form {display: flex;flex-direction: column;gap: 1.2rem;}
    .modal-body label {
      font-weight: 500;text-align: left;color: #333;font-size: 0.95rem;
      display: block;margin-bottom: 0.5rem;
    }
    .modal-body input {
      width: 100%;padding: 0.8rem;border: 1px solid #ddd;border-radius: 8px;
      font-size: 0.95rem;transition: border-color 0.2s;
    }
    .modal-body input:focus {outline: none;border-color: var(--primary);}
    .modal-footer {padding: 0 2rem 2rem;text-align: center;}
    .modal-footer p {margin-top: 1rem;font-size: 0.9rem;color: #666;}
    .modal-footer a {color: var(--primary);text-decoration: none;font-weight: 500;}
    .modal-footer a:hover {text-decoration: underline;}

    /* Responsive */
    @media(max-width:768px){
      h1{font-size:2.5rem;}
      .hero p{font-size:1.1rem;}
      .hero-buttons{flex-direction:column;align-items:stretch;}
      .nav-logo{font-size:1.2rem;}
      .nav-links{display:none;}
      section{padding:3rem 1rem;}
      .container{padding:2rem;}
      .stats{grid-template-columns:repeat(2,1fr);}
    }
  </style>
</head>
<body>
  <nav class="scroll-nav" aria-label="Primary">
    <div class="nav-inner">
      <div class="nav-logo"><span class="nav-logo-icon">🏠</span><span>CozyDorms</span></div>
      <div class="nav-links" id="navLinks">
        <div class="nav-indicator" id="navIndicator"></div>
        <a href="#home" data-target="home" class="nav-link active">Home</a>
        <a href="#featured" data-target="featured" class="nav-link">Dorms</a>
        <a href="#features" data-target="features" class="nav-link">Features</a>
        <a href="#testimonials" data-target="testimonials" class="nav-link">Reviews</a>
      </div>
      <button id="loginBtn" class="btn nav-btn" aria-label="Access Portal">Access Portal</button>
    </div>
  </nav>

  <!-- Login Modal -->
  <div id="loginModal" class="modal">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Welcome Back</h2>
        <button class="close" id="closeModal">&times;</button>
      </div>
      <div class="modal-body">
        <?php if ($error): ?>
          <div class="alert"><?= htmlspecialchars($error) ?></div>
          <script>
            document.addEventListener('DOMContentLoaded', function() {
              document.getElementById('loginModal').style.display = 'block';
            });
          </script>
        <?php endif; ?>
        <form method="post" autocomplete="off">
          <div>
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required>
          </div>
          <div>
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>
          </div>
          <button type="submit" name="login" class="btn" style="width: 100%;">Log In</button>
        </form>
      </div>
      <div class="modal-footer">
        <p>Don't have an account? <a href="../auth/register.php">Sign Up</a></p>
      </div>
    </div>
  </div>

  <div style="height:72px"></div>

  <!-- Hero -->
  <section id="home">
    <div class="container hero" data-aos="fade-up">
      <div class="hero-badge" data-aos="fade-down">🎓 Trusted by <?= number_format($total_students) ?>+ Students</div>
      <div class="logo floating">🏠</div>
      <h1>Find Your Perfect <span class="gradient-text">Student Home</span></h1>
      <p>The most comprehensive student housing platform. Browse <?= $total_dorms ?> verified dormitories, book instantly, and manage everything in one place.</p>
      <div class="hero-buttons">
        <button id="heroLoginBtn" class="btn">Get Started</button>
        <a href="#featured" class="btn btn-secondary">Browse Dorms</a>
      </div>
    </div>
  </section>

  <!-- Stats -->
  <section id="stats" style="min-height:auto;padding:3rem 1.5rem;">
    <div class="container" data-aos="fade-up">
      <h2>Trusted Platform</h2>
      <p class="section-subtitle">Join thousands of students and property owners who trust CozyDorms</p>
      <div class="stats">
        <div class="stat-card" data-aos="fade-up" data-aos-delay="100">
          <div class="stat-number"><?= number_format($total_students) ?>+</div>
          <div class="stat-label">Active Students</div>
        </div>
        <div class="stat-card" data-aos="fade-up" data-aos-delay="200">
          <div class="stat-number"><?= number_format($total_dorms) ?>+</div>
          <div class="stat-label">Listed Dorms</div>
        </div>
        <div class="stat-card" data-aos="fade-up" data-aos-delay="300">
          <div class="stat-number"><?= number_format($total_bookings) ?>+</div>
          <div class="stat-label">Successful Bookings</div>
        </div>
        <div class="stat-card" data-aos="fade-up" data-aos-delay="400">
          <div class="stat-number"><?= number_format($total_owners) ?>+</div>
          <div class="stat-label">Property Owners</div>
        </div>
      </div>
    </div>
  </section>

  <!-- Featured Dorms -->
  <?php if (!empty($featured_dorms)): ?>
  <section id="featured">
    <div class="container" data-aos="fade-up">
      <h2>Featured Dorms</h2>
      <p class="section-subtitle">Check out our newest and most popular student accommodations</p>
      <div class="dorms-grid">
        <?php foreach ($featured_dorms as $index => $dorm): ?>
        <div class="dorm-card" data-aos="fade-up" data-aos-delay="<?= ($index + 1) * 100 ?>">
          <div class="dorm-image" style="background-image:url('<?= !empty($dorm['image_url']) ? htmlspecialchars($dorm['image_url']) : '../assets/images/default-dorm.jpg' ?>')">
            <div class="dorm-badge">Available</div>
          </div>
          <div class="dorm-content">
            <div class="dorm-title"><?= htmlspecialchars($dorm['name']) ?></div>
            <div class="dorm-info">📍 <?= htmlspecialchars($dorm['address'] ?? 'Location') ?></div>
            <div class="dorm-info">👤 By <?= htmlspecialchars($dorm['owner_name']) ?></div>
            <div class="dorm-price">₱<?= number_format($dorm['price_per_month'] ?? 0) ?><span style="font-size:0.9rem;font-weight:400;color:var(--gray-600);">/month</span></div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>
  <?php endif; ?>

  <!-- Features -->
  <section id="features">
    <div class="container" data-aos="fade-up">
      <h2>Everything You Need</h2>
      <p class="section-subtitle">Powerful features designed to make student housing management effortless</p>
      <div class="features">
        <div class="feature-card" data-aos="fade-up" data-aos-delay="100">
          <div class="feature-icon">🔍</div>
          <h3>Advanced Search</h3>
          <p>Find your ideal dorm with smart filters for location, price, amenities, and distance from campus.</p>
        </div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="200">
          <div class="feature-icon">⚡</div>
          <h3>Instant Booking</h3>
          <p>Book your accommodation instantly with our streamlined reservation system. No waiting, no hassle.</p>
        </div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="300">
          <div class="feature-icon">💳</div>
          <h3>Secure Payments</h3>
          <p>Track payments, upload receipts, and manage your finances all in one secure platform.</p>
        </div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="100">
          <div class="feature-icon">💬</div>
          <h3>Direct Messaging</h3>
          <p>Communicate directly with landlords and property managers through our integrated chat system.</p>
        </div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="200">
          <div class="feature-icon">📊</div>
          <h3>Owner Dashboard</h3>
          <p>Property owners get comprehensive analytics, booking management, and tenant communication tools.</p>
        </div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="300">
          <div class="feature-icon">🔒</div>
          <h3>Verified Listings</h3>
          <p>All properties are verified and inspected to ensure quality and safety for our students.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- Testimonials -->
  <section id="testimonials" style="min-height:auto;padding:3rem 1.5rem;">
    <div class="container" data-aos="fade-up">
      <h2>What Our Users Say</h2>
      <p class="section-subtitle">Real experiences from students using CozyDorms</p>
      <div class="testimonials">
        <?php if (!empty($testimonials)): ?>
          <?php foreach ($testimonials as $index => $testimonial): ?>
          <div class="testimonial-card" data-aos="fade-up" data-aos-delay="<?= ($index + 1) * 100 ?>">
            <div class="testimonial-quote">
              "Booked <?= htmlspecialchars($testimonial['dorm_name']) ?> through CozyDorms. The platform made finding student housing incredibly easy and stress-free!"
            </div>
            <div class="testimonial-author">
              <div class="testimonial-avatar"><?= strtoupper(substr($testimonial['name'], 0, 2)) ?></div>
              <div class="testimonial-info">
                <h4><?= htmlspecialchars($testimonial['name']) ?></h4>
                <p>Student</p>
              </div>
            </div>
          </div>
          <?php endforeach; ?>
        <?php else: ?>
          <div class="testimonial-card" data-aos="fade-up" data-aos-delay="100">
            <div class="testimonial-quote">
              "CozyDorms made finding housing so easy! I found the perfect dorm near campus within minutes. The booking process was seamless."
            </div>
            <div class="testimonial-author">
              <div class="testimonial-avatar">MJ</div>
              <div class="testimonial-info">
                <h4>Maria Johnson</h4>
                <p>Computer Science Student</p>
              </div>
            </div>
          </div>
          <div class="testimonial-card" data-aos="fade-up" data-aos-delay="200">
            <div class="testimonial-quote">
              "As a property owner, this platform has transformed how I manage my rentals. The dashboard is intuitive and payment tracking is brilliant!"
            </div>
            <div class="testimonial-author">
              <div class="testimonial-avatar">RC</div>
              <div class="testimonial-info">
                <h4>Robert Chen</h4>
                <p>Property Owner</p>
              </div>
            </div>
          </div>
          <div class="testimonial-card" data-aos="fade-up" data-aos-delay="300">
            <div class="testimonial-quote">
              "The messaging feature is fantastic. I can communicate with my landlord instantly, and everything is documented in one place."
            </div>
            <div class="testimonial-author">
              <div class="testimonial-avatar">SA</div>
              <div class="testimonial-info">
                <h4>Sarah Anderson</h4>
                <p>Engineering Student</p>
              </div>
            </div>
          </div>
        <?php endif; ?>
      </div>
    </div>
  </section>

  <!-- CTA -->
  <section style="min-height:auto;padding:3rem 1.5rem;">
    <div class="container" data-aos="fade-up">
      <div class="cta-section">
        <h2>Ready to Find Your Perfect Dorm?</h2>
        <p>Join <?= number_format($total_students) ?>+ students who have found their ideal accommodation through CozyDorms</p>
        <div class="cta-buttons">
          <button id="ctaLoginBtn" class="btn" style="background:white;color:var(--primary);">Access Portal Now</button>
          <a href="#features" class="btn btn-secondary" style="background:transparent;border-color:white;color:white;">Explore Features</a>
        </div>
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="footer">
    <div class="footer-content">
      <div class="footer-section">
        <h4>🏠 CozyDorms</h4>
        <p>Making student housing simple, accessible, and transparent for everyone.</p>
      </div>
      <div class="footer-section">
        <h4>Quick Links</h4>
        <ul>
          <li><a href="#home">Home</a></li>
          <li><a href="#featured">Dorms</a></li>
          <li><a href="#features">Features</a></li>
          <li><a href="#testimonials">Reviews</a></li>
        </ul>
      </div>
      <div class="footer-section">
        <h4>For Students</h4>
        <ul>
          <li><a href="../auth/register.php">Sign Up</a></li>
          <li><a href="#" id="footerLoginBtn">Login</a></li>
          <li><a href="#featured">Browse Dorms</a></li>
          <li><a href="#features">How It Works</a></li>
        </ul>
      </div>
      <div class="footer-section">
        <h4>For Owners</h4>
        <ul>
          <li><a href="../auth/register_admin.php">List Your Property</a></li>
          <li><a href="#" id="footerOwnerLogin">Owner Login</a></li>
          <li><a href="#features">Management Tools</a></li>
          <li><a href="#stats">Statistics</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2025 CozyDorms. All rights reserved. | Making student life easier, one dorm at a time.</p>
    </div>
  </footer>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.js"></script>
  <script>
    AOS.init({ duration: 800, once: true, offset: 100 });

    const modal = document.getElementById('loginModal');
    const loginBtn = document.getElementById('loginBtn');
    const heroLoginBtn = document.getElementById('heroLoginBtn');
    const ctaLoginBtn = document.getElementById('ctaLoginBtn');
    const footerLoginBtn = document.getElementById('footerLoginBtn');
    const footerOwnerLogin = document.getElementById('footerOwnerLogin');
    const closeModal = document.getElementById('closeModal');

    function openModal() {
      modal.style.display = 'block';
      document.getElementById('email').focus();
    }

    if(loginBtn) loginBtn.onclick = openModal;
    if(heroLoginBtn) heroLoginBtn.onclick = openModal;
    if(ctaLoginBtn) ctaLoginBtn.onclick = openModal;
    if(footerLoginBtn) {
      footerLoginBtn.onclick = function(e) {
        e.preventDefault();
        openModal();
      }
    }
    if(footerOwnerLogin) {
      footerOwnerLogin.onclick = function(e) {
        e.preventDefault();
        openModal();
      }
    }

    if(closeModal) {
      closeModal.onclick = function() {
        modal.style.display = 'none';
      }
    }

    window.onclick = function(event) {
      if (event.target == modal) {
        modal.style.display = 'none';
      }
    }

    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && modal.style.display === 'block') {
        modal.style.display = 'none';
      }
    });

    const nav = document.querySelector('.scroll-nav');
    window.addEventListener('scroll', function() {
      if (window.scrollY > 50) {
        nav.classList.add('scrolled');
      } else {
        nav.classList.remove('scrolled');
      }
    });

    const navLinks = document.querySelectorAll('.nav-link');
    const indicator = document.getElementById('navIndicator');

    function initIndicator() {
      const active = document.querySelector('.nav-link.active');
      if (active && indicator) {
        indicator.style.left = active.offsetLeft + 'px';
        indicator.style.width = active.offsetWidth + 'px';
      }
    }

    navLinks.forEach(link => {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        navLinks.forEach(l => l.classList.remove('active'));
        this.classList.add('active');
        initIndicator();

        const target = this.getAttribute('data-target');
        const section = document.getElementById(target);
        if (section) {
          const navHeight = nav.offsetHeight;
          const sectionTop = section.offsetTop - navHeight - 20;
          window.scrollTo({ top: sectionTop, behavior: 'smooth' });
        }
      });
    });

    const sections = document.querySelectorAll('section[id]');
    window.addEventListener('scroll', () => {
      let current = '';
      sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 250) {
          current = section.getAttribute('id');
        }
      });

      navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('data-target') === current) {
          link.classList.add('active');
          initIndicator();
        }
      });
    });

    initIndicator();
    window.addEventListener('resize', initIndicator);
    setTimeout(initIndicator, 200);
  </script>
</body>
</html>
