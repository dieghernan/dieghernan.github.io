// Add anchors for headings
// Adapted from Minimal Mistakes, (c) Michael Rose
$('#maincontent').find('h1, h2, h3, h4, h5, h6').each(function() {
  var id = $(this).attr('id');
  if (id) {
    var anchor = document.createElement("a");

    anchor.classList.add('chulapa-header-link', 'ml-2', 'chulapaDateSocial');
    anchor.href = '#' + id;
    anchor.innerHTML = '<span class=\"sr-only\">Permalink</span><i class=\"fas fa-link fa-2xs align-middle\"></i>';
    anchor.title = "Permalink";
    $(this).append(anchor);
  }
});

// Start Copy Clipboard

// Initialize Bootstrap tooltip
$(function() {
  $('[data-toggle="tooltip"]')
    .tooltip()
})

function showTooltip(btn, message) {
  btn.tooltip('hide')
    .attr('data-original-title', message)
    .tooltip('show');
}

function hideTooltip(btn) {
  setTimeout(function() {
    btn.tooltip('hide');
  }, 1000);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function setTooltip(btn, tooltip, style) {
  btn.classList.remove('text-muted');
  btn.classList.add(style);
  btn.setAttribute('aria-label', tooltip);
  await sleep(1000);
  btn.classList.add('text-muted');
  btn.setAttribute('aria-label', 'Copy code to clipboard');
  btn.removeAttribute('data-original-title');
  btn.classList.remove(style);
}

// End helpers tooltip

// Insert buttons 
function ch_clipboard_setup() {
  var d = document;
  var els = d.querySelectorAll('pre');
  for (var i = 0; i < els.length; i++) {
    // Select all pre codes
    var preBlock = els[i];
    // Select first child	
    let codeBlock = preBlock.firstChild;

    // If first child is code
    if (codeBlock.tagName.toLowerCase() == 'code') {
      // Add id to code block
      codeBlock.setAttribute('id', 'clipboard_code' + i);
      // Create button			
      var btn = d.createElement('button');
      btn.classList.add('btn', 'text-muted', 'btn-sm', 'btn-chulapa-copy-code');
      btn.innerHTML = "<i class='far fa-copy'></i>";
      btn.id = 'clipboard_btn' + i;
      btn.type = 'button';
      btn.setAttribute('data-toggle', 'tooltip');
      btn.setAttribute('data-placement', 'left');
      btn.setAttribute('aria-label', 'Copy code to clipboard');
      //Function to copy to clipboard
      btn.onclick = ch_copy_cliboard(i);
      preBlock.prepend(btn);
    } else {
      console.log('No code block for\n' + preBlock.innerHTML);
    }
  }
}

function ch_copy_cliboard(i) {
  return function() {
    var d = document;
    // Select code content and strip HTML
    var codeBlock = d.getElementById('clipboard_code' + i)
      .innerHTML;
    codeBlockStripped = stripHtml(codeBlock);

    // Reset clipboard
    navigator.clipboard.writeText('');

    var btn = d.getElementById('clipboard_btn' + i);
    var btnTrigger = $(btn);

    // Set initial values

    let style = 'text-success';
    let msg = 'Copied on the clipboard:\n' + codeBlockStripped;
    let tooltip = 'Copied!';
    try {
      navigator.clipboard.writeText(codeBlockStripped);
    } catch {
      // Modify on error
      style = 'text-danger';
      tooltip = 'Error!';
      msg = 'Error when copying the code';
    }
    setTooltip(btn, tooltip, style);
    showTooltip(btnTrigger, tooltip);
    hideTooltip(btnTrigger);
    console.log(msg);
  }
}
// stripHtml safely
function stripHtml(html) {
  let tmp = document.createElement('DIV');
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText || '';
}

window.addEventListener('load', ch_clipboard_setup);

// End CopyClipboard

// SideBar ToC

function setupSideBar() {
  var sT = document.getElementById("sidetoc");
  var btn = document.getElementById("demo");
  var body = document.getElementById("body");
  // Create hidden overlay
  var iDiv = document.createElement("div");
  if (sT) {
    btn.style.marginLeft = "0";
    iDiv.classList.add("bs-canvas-overlay", "bg-dark", "position-fixed",
      "w-100", "h-100");
    iDiv.setAttribute("id", "sideBarOverlay");
    iDiv.setAttribute("onclick", "closeSideBar()");
    body.prepend(iDiv);
  } else if (btn) {
  
    // ToC was requested but no toc produced
    // Clean up DOM
    btn.remove();
    document.getElementById("sideBar")
      .remove();
  }
}
window.addEventListener("load", setupSideBar);

function openSideBar() {
  var btn = document.getElementById("demo");
  btn.removeAttribute('style');
  btn.setAttribute("aria-expanded", "true");
  document.getElementById("sideBarOverlay")
    .classList.add("show");
  document.getElementById("sideBar")
    .style.marginLeft = "0";
}

function closeSideBar() {
  var btn = document.getElementById("demo");
  document.getElementById("sideBar")
    .removeAttribute("style");
  document.getElementById("sideBarOverlay")
    .classList.remove("show");
  btn.style.marginLeft = "0";
  btn.setAttribute("aria-expanded", "false");
}
