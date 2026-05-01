$(document).ready(function(){
  // Loading overlay
  var overlay = $('<div class="loading-overlay" id="appLoader">' +
    '<div style="width:48px;height:48px;border:3px solid rgba(99,132,255,.15);border-top-color:#6384ff;border-radius:50%;animation:spin .8s linear infinite"></div>' +
    '<div style="margin-top:16px;font-size:13px;color:#8b8fa3;font-weight:500">Initializing System...</div></div>');
  $('body').append(overlay);
  setTimeout(function(){ $('#appLoader').fadeOut(500, function(){ $(this).remove(); }); }, 1500);

  // Shiny busy indicator
  $(document).on('shiny:busy', function(){
    if(!$('#busySpinner').length){
      $('body').append('<div id="busySpinner" style="position:fixed;top:72px;right:32px;z-index:999;display:flex;align-items:center;gap:8px;background:rgba(30,33,48,.9);backdrop-filter:blur(10px);padding:10px 18px;border-radius:10px;border:1px solid rgba(99,132,255,.2);animation:fadeUp .3s ease">' +
        '<div style="width:16px;height:16px;border:2px solid rgba(99,132,255,.2);border-top-color:#6384ff;border-radius:50%;animation:spin .7s linear infinite"></div>' +
        '<span style="font-size:12px;color:#8b8fa3;font-weight:500">Processing...</span></div>');
    }
  });
  $(document).on('shiny:idle', function(){ $('#busySpinner').fadeOut(300, function(){ $(this).remove(); }); });

  // Tab transition effect
  $(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function(){
    var target = $($(this).attr('href'));
    target.css({opacity:0, transform:'translateY(12px)'});
    setTimeout(function(){ target.css({transition:'all .4s ease', opacity:1, transform:'translateY(0)'}); }, 50);
  });

  // Animate cards on scroll
  var observer = new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      if(e.isIntersecting){
        e.target.style.opacity = '1';
        e.target.style.transform = 'translateY(0)';
      }
    });
  }, {threshold:0.1});

  function observeCards(){
    document.querySelectorAll('.card,.metric-card,.plot-container,.insight-block').forEach(function(el){
      if(!el.dataset.observed){
        el.dataset.observed = 'true';
        el.style.opacity = '0';
        el.style.transform = 'translateY(16px)';
        el.style.transition = 'all .5s ease';
        observer.observe(el);
      }
    });
  }
  observeCards();
  setInterval(observeCards, 2000);

  // Button ripple
  $(document).on('click', '.btn-primary, .btn-run', function(e){
    var btn = $(this);
    var ripple = $('<span style="position:absolute;border-radius:50%;background:rgba(255,255,255,.25);transform:scale(0);animation:ripple .6s ease-out;pointer-events:none"></span>');
    var d = Math.max(btn.outerWidth(), btn.outerHeight());
    ripple.css({width:d, height:d, left:e.pageX - btn.offset().left - d/2, top:e.pageY - btn.offset().top - d/2});
    btn.css('position','relative').append(ripple);
    setTimeout(function(){ ripple.remove(); }, 600);
  });
});

// Ripple keyframe
var style = document.createElement('style');
style.textContent = '@keyframes ripple{to{transform:scale(2.5);opacity:0}}';
document.head.appendChild(style);
