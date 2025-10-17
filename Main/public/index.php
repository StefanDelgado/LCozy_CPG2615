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

// Handle login form submission
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    require_once __DIR__ . '/../config.php';
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
  <title>CozyDorms - Student Housing Management System</title>
  <!-- AOS (Animate On Scroll) library stylesheet -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.css"/>
  <style>
    /* Define CSS variables for theme colors */
    :root{
      --accent:#4A3AFF;
      --accent-dark:#372fdb;
      --muted:#666;
      --nav-bg:#ffffff;
      --nav-group-bg:#f0f0f0;
    }

    /* Reset and base styles */
    *{box-sizing:border-box}
    body{
      margin:0;
      font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
      color:#1f1147;
      background: linear-gradient(135deg,#a18cd1 0%,#fbc2eb 100%);
      scroll-behavior:smooth;
    }

    /* Section styles */
    section{min-height:100vh;display:flex;justify-content:center;align-items:center;padding:2rem 1rem;}
    .container{background:white;padding:2.5rem;border-radius:16px;box-shadow:0 8px 20px rgba(0,0,0,.1);max-width:1200px;width:100%;text-align:center;}

    /* Navigation bar styles */
    .scroll-nav{
      position:fixed;left:0;right:0;top:0;
      display:flex;justify-content:center;align-items:center;
      background:var(--nav-bg);
      padding:12px 16px;
      box-shadow:0 2px 10px rgba(0,0,0,.08);
      z-index:1200;
    }
    .nav-inner{
      display:flex;align-items:center;gap:16px;position:relative;width:100%;max-width:980px;justify-content:center;
    }

    /* Navigation links and indicator */
    .nav-links{
      display:flex;gap:12px;padding:6px;border-radius:10px;background:var(--nav-group-bg);
      position:relative;
    }
    .nav-link{
      padding:10px 20px;border-radius:8px;text-decoration:none;color:#444;font-weight:500;
      transition:color .3s;position:relative;z-index:2;
    }
    .nav-link.active{color:#1f1147}
    .nav-link:hover{color:#1f1147}
    .nav-indicator{
      position:absolute;background:white;border-radius:8px;
      transition:left .3s cubic-bezier(.4,0,.2,1), width .3s cubic-bezier(.4,0,.2,1);
      height:calc(100% - 12px);top:6px;box-shadow:0 2px 4px rgba(0,0,0,.08);z-index:1;
    }

    /* Button styles */
    .btn{
      display:inline-block;padding:12px 28px;background:var(--accent);color:white;
      text-decoration:none;border-radius:10px;font-weight:600;transition:background .3s, transform .2s;
      cursor: pointer;
      border: none;
      font-size: 1rem;
    }
    .btn:hover{background:var(--accent-dark);transform:scale(1.03)}
    .btn:active{transform:scale(0.98)}
    .nav-btn{padding:10px 24px;font-size:0.95rem}

    /* Hero section */
    .hero{text-align:center;max-width:700px}
    .logo{font-size:5rem;margin-bottom:1rem;animation:bounce 2s infinite}
    @keyframes bounce{0%,100%{transform:translateY(0)} 50%{transform:translateY(-10px)}}
    h1{font-size:3rem;margin:0.5rem 0;color:#1f1147}
    .hero p{font-size:1.3rem;color:var(--muted);margin:1rem 0 2rem}

    /* Features section */
    .features{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:1.5rem;margin-top:2rem}
    .feature-card{background:#f8f8ff;padding:1.8rem;border-radius:12px;transition:transform .3s, box-shadow .3s}
    .feature-card:hover{transform:translateY(-5px);box-shadow:0 6px 15px rgba(0,0,0,.12)}
    .feature-icon{font-size:3rem;margin-bottom:0.5rem}
    h2{font-size:2.5rem;margin-bottom:1rem;color:#1f1147}
    h3{font-size:1.4rem;margin:0.5rem 0;color:#333}
    p{color:var(--muted);line-height:1.6}

    /* About section */
    .about-section{display:grid;grid-template-columns:1fr 1fr;gap:2rem;margin-top:2rem;text-align:left}
    @media(max-width:768px){
      .about-section{grid-template-columns:1fr}
      h1{font-size:2rem}
      .hero p{font-size:1.1rem}
    }

    /* Modal styles */
    .modal {
      display: none;
      position: fixed;
      z-index: 2000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0,0,0,0.6);
      animation: fadeIn 0.3s;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    
    .modal-content {
      background-color: #fff;
      margin: 5% auto;
      padding: 0;
      border-radius: 16px;
      width: 90%;
      max-width: 420px;
      box-shadow: 0 8px 30px rgba(0,0,0,0.3);
      animation: slideDown 0.3s;
      position: relative;
    }
    
    @keyframes slideDown {
      from {
        transform: translateY(-50px);
        opacity: 0;
      }
      to {
        transform: translateY(0);
        opacity: 1;
      }
    }
    
    .modal-header {
      padding: 1.5rem 2rem;
      border-bottom: 1px solid #eee;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .modal-header h2 {
      margin: 0;
      font-size: 1.5rem;
      color: #1f1147;
    }
    
    .close {
      color: #aaa;
      font-size: 28px;
      font-weight: bold;
      cursor: pointer;
      background: none;
      border: none;
      padding: 0;
      width: 30px;
      height: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 50%;
      transition: background 0.2s, color 0.2s;
    }
    
    .close:hover,
    .close:focus {
      background: #f0f0f0;
      color: #000;
    }
    
    .modal-body {
      padding: 2rem;
    }
    
    .modal-body .alert {
      background: #f8d7da;
      color: #721c24;
      padding: 0.8rem;
      border-radius: 8px;
      margin-bottom: 1rem;
      font-size: 0.9rem;
    }
    
    .modal-body form {
      display: flex;
      flex-direction: column;
      gap: 1.2rem;
    }
    
    .modal-body label {
      font-weight: 500;
      text-align: left;
      color: #333;
      font-size: 0.95rem;
      display: block;
      margin-bottom: 0.5rem;
    }
    
    .modal-body input {
      width: 100%;
      padding: 0.8rem;
      border: 1px solid #ddd;
      border-radius: 8px;
      font-size: 0.95rem;
      transition: border-color 0.2s;
    }
    
    .modal-body input:focus {
      outline: none;
      border-color: var(--accent);
    }
    
    .modal-footer {
      padding: 0 2rem 2rem;
      text-align: center;
    }
    
    .modal-footer p {
      margin-top: 1rem;
      font-size: 0.9rem;
      color: #666;
    }
    
    .modal-footer a {
      color: var(--accent);
      text-decoration: none;
      font-weight: 500;
    }
    
    .modal-footer a:hover {
      text-decoration: underline;
    }

  </style>
</head>
<body>
  <!-- Navigation bar -->
  <nav class="scroll-nav" aria-label="Primary">
    <div class="nav-inner">
      <div class="nav-links" id="navLinks">
        <div class="nav-indicator" id="navIndicator"></div>
        <a href="#home" data-target="home" class="nav-link active">Home</a>
        <a href="#features" data-target="features" class="nav-link">Features</a>
        <a href="#about" data-target="about" class="nav-link">About</a>
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
            // Show modal if there's an error
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

  <!-- Spacer to prevent content from being hidden under fixed nav -->
  <div style="height:68px"></div>

  <!-- Hero section -->
  <section id="home">
    <div class="container hero" data-aos="fade-up">
      <div class="logo">🏠</div>
      <h1>Welcome to CozyDorms</h1>
      <p>Your complete student housing management solution. Access dorm listings, manage bookings, and more.</p>
      <button id="heroLoginBtn" class="btn">Access Portal</button>
    </div>
  </section>

  <!-- Features section -->
  <section id="features">
    <div class="container" data-aos="fade-up">
      <h2>Our Features</h2>
      <div class="features">
        <div class="feature-card" data-aos="fade-up" data-aos-delay="100"><div class="feature-icon">🔍</div><h3>Easy Search</h3><p>Find your perfect dorm with filters.</p></div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="200"><div class="feature-icon">📱</div><h3>Online Booking</h3><p>Book accommodation instantly.</p></div>
        <div class="feature-card" data-aos="fade-up" data-aos-delay="300"><div class="feature-icon">🕜</div><h3>Manage Payments</h3><p>Never again forget to pay!</p></div>
      </div>
    </div>
  </section>

  <!-- About section -->
  <section id="about">
    <div class="container" data-aos="fade-up">
      <h2>About CozyDorms</h2>
      <div class="about-section">
        <div data-aos="fade-right">
          <h3>Our Mission</h3>
          <p>CozyDorms makes student housing simple and accessible.</p>
        </div>
        <div data-aos="fade-left">
          <h3>Why Choose Us</h3>
          <p>We provide a complete solution for students and landlords alike.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- AOS library script -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.js"></script>
  <script>
    // Initialize AOS animations
    AOS.init({ duration: 800, once: true });

    // Modal functionality
    const modal = document.getElementById('loginModal');
    const loginBtn = document.getElementById('loginBtn');
    const heroLoginBtn = document.getElementById('heroLoginBtn');
    const closeModal = document.getElementById('closeModal');

    // Open modal when clicking Access Portal buttons
    loginBtn.onclick = function() {
      modal.style.display = 'block';
    }
    
    heroLoginBtn.onclick = function() {
      modal.style.display = 'block';
    }

    // Close modal when clicking X
    closeModal.onclick = function() {
      modal.style.display = 'none';
    }

    // Close modal when clicking outside of it
    window.onclick = function(event) {
      if (event.target == modal) {
        modal.style.display = 'none';
      }
    }

    // Navigation indicator functionality
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
          section.scrollIntoView({ behavior: 'smooth' });
        }
      });
    });

    // Scroll spy functionality
    const sections = document.querySelectorAll('section[id]');
    window.addEventListener('scroll', () => {
      let current = '';
      sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 200) {
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

    // Initialize indicator on page load
    initIndicator();
    window.addEventListener('resize', initIndicator);

    // Ensure the indicator is correctly positioned after animations
    setTimeout(initIndicator, 200);
  </script>
</body>
</html>
