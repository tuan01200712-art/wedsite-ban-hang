// STYLE HUB - Website demo sử dụng localStorage (chưa có máy chủ/database thật)
const STORAGE = {
  products: "stylehub_products",
  users: "stylehub_users",
  orders: "stylehub_orders",
  cart: "stylehub_cart",
  current: "stylehub_current_user"
};

const defaultProducts = [
  {id:1,name:"Áo thun Basic",category:"Áo",price:159000,image:"https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600",description:"Áo thun cotton đơn giản, dễ phối đồ."},
  {id:2,name:"Áo sơ mi trắng",category:"Áo",price:259000,image:"https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=600",description:"Sơ mi thanh lịch phù hợp nhiều dịp."},
  {id:3,name:"Quần jeans",category:"Quần",price:389000,image:"https://images.unsplash.com/photo-1542272604-787c3835535d?w=600",description:"Quần jeans phong cách trẻ trung."},
  {id:4,name:"Giày sneaker",category:"Giày",price:599000,image:"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600",description:"Giày sneaker năng động hằng ngày."},
  {id:5,name:"Giày thể thao",category:"Giày",price:729000,image:"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600",description:"Thiết kế thể thao, dễ vận động."},
  {id:6,name:"Balo thời trang",category:"Phụ kiện",price:299000,image:"https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600",description:"Balo tiện dụng cho học tập và đi chơi."},
  {id:7,name:"Áo khoác",category:"Áo",price:459000,image:"https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600",description:"Áo khoác ngoài cá tính."},
  {id:8,name:"Mũ lưỡi trai",category:"Phụ kiện",price:119000,image:"https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=600",description:"Phụ kiện đơn giản cho outfit."}
];

function read(key, fallback) {
  try { return JSON.parse(localStorage.getItem(key)) ?? fallback; }
  catch { return fallback; }
}
function save(key, value) { localStorage.setItem(key, JSON.stringify(value)); }

let products = read(STORAGE.products, null);
if (!products) { products = defaultProducts; save(STORAGE.products, products); }
let users = read(STORAGE.users, []);
let orders = read(STORAGE.orders, []);
let cart = read(STORAGE.cart, []);
let currentUser = read(STORAGE.current, null);
let authMode = "login";

function money(value) { return Number(value).toLocaleString("vi-VN") + "đ"; }
function escapeHTML(value) {
  return String(value ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
}
function persistCart() { save(STORAGE.cart, cart); }
function isAdmin() { return currentUser && currentUser.role === "admin"; }

function showPage(page) {
  if (page === "admin" && !isAdmin()) { alert("Bạn cần đăng nhập bằng tài khoản quản trị."); openAuth("login"); return; }
  document.querySelectorAll(".page").forEach(el => el.hidden = true);
  document.getElementById(page + "Page").hidden = false;
  document.querySelectorAll(".nav-link").forEach(el => el.classList.toggle("active", el.dataset.page === page));
  if (page === "cart") renderCart();
  if (page === "orders") renderOrders();
  if (page === "admin") renderAdmin();
  window.scrollTo({top:0,behavior:"smooth"});
}

function renderProducts() {
  const keyword = (document.getElementById("searchInput")?.value || "").trim().toLowerCase();
  const category = document.getElementById("categoryFilter")?.value || "all";
  const sort = document.getElementById("sortFilter")?.value || "default";
  let list = products.filter(p => p.name.toLowerCase().includes(keyword) && (category === "all" || p.category === category));
  if (sort === "low") list.sort((a,b) => a.price-b.price);
  if (sort === "high") list.sort((a,b) => b.price-a.price);
  if (sort === "name") list.sort((a,b) => a.name.localeCompare(b.name,"vi"));
  document.getElementById("productTotal").textContent = list.length + " sản phẩm";
  document.getElementById("productGrid").innerHTML = list.length ? list.map(p => `
    <article class="product-card">
      <img src="${escapeHTML(p.image || "")}" alt="${escapeHTML(p.name)}" onerror="this.src='https://placehold.co/600x600/f7f5f0/777?text=STYLE+HUB'">
      <div class="category">${escapeHTML(p.category)}</div>
      <h3>${escapeHTML(p.name)}</h3>
      <div class="price">${money(p.price)}</div>
      <button class="primary-btn" onclick="addToCart(${p.id})">Thêm vào giỏ</button>
    </article>`).join("") : `<div class="empty">Không tìm thấy sản phẩm phù hợp.</div>`;
}

function addToCart(id) {
  if (!currentUser) { alert("Vui lòng đăng nhập trước khi thêm hàng vào giỏ."); openAuth("login"); return; }
  const product = products.find(p => p.id === id);
  if (!product) return;
  const item = cart.find(p => p.id === id);
  if (item) item.quantity++;
  else cart.push({id:product.id,quantity:1});
  persistCart(); updateCartCount(); alert("Đã thêm sản phẩm vào giỏ hàng!");
}
function updateCartCount() {
  document.getElementById("cartCount").textContent = cart.reduce((sum,item) => sum + item.quantity,0);
}
function renderCart() {
  const holder = document.getElementById("cartItems");
  let total = 0;
  holder.innerHTML = cart.length ? cart.map(item => {
    const p = products.find(product => product.id === item.id);
    if (!p) return "";
    total += p.price * item.quantity;
    return `<div class="cart-row">
      <img src="${escapeHTML(p.image)}" alt="${escapeHTML(p.name)}" onerror="this.src='https://placehold.co/100'">
      <div><b>${escapeHTML(p.name)}</b><div class="price">${money(p.price)}</div></div>
      <div class="qty"><button onclick="changeQty(${p.id},-1)">−</button><span>${item.quantity}</span><button onclick="changeQty(${p.id},1)">+</button></div>
      <button class="remove-btn" onclick="removeCartItem(${p.id})">Xóa</button>
    </div>`;
  }).join("") : `<div class="empty">Giỏ hàng đang trống.<br><button class="text-btn" onclick="showPage('shop')">Tiếp tục mua sắm</button></div>`;
  document.getElementById("subtotal").textContent = money(total);
  document.getElementById("cartTotal").textContent = money(total);
}
function changeQty(id, amount) {
  const item = cart.find(p => p.id === id);
  if (!item) return;
  item.quantity += amount;
  if (item.quantity <= 0) cart = cart.filter(p => p.id !== id);
  persistCart(); updateCartCount(); renderCart();
}
function removeCartItem(id) {
  cart = cart.filter(p => p.id !== id);
  persistCart(); updateCartCount(); renderCart();
}

function checkout() {
  if (!currentUser) { openAuth("login"); return; }
  if (!cart.length) { alert("Giỏ hàng đang trống."); return; }
  const customer = prompt("Nhập họ tên người nhận:");
  if (!customer || !customer.trim()) return;
  const phone = prompt("Nhập số điện thoại:");
  if (!phone || !phone.trim()) return;
  const address = prompt("Nhập địa chỉ giao hàng:");
  if (!address || !address.trim()) return;
  const items = cart.map(item => {
    const p = products.find(product => product.id === item.id);
    return p ? {id:p.id,name:p.name,price:p.price,quantity:item.quantity} : null;
  }).filter(Boolean);
  const total = items.reduce((sum,p) => sum + p.price*p.quantity,0);
  orders.unshift({id:Date.now(),username:currentUser.username,customer:customer.trim(),phone:phone.trim(),address:address.trim(),items,total,status:"Chờ xác nhận",createdAt:new Date().toLocaleString("vi-VN")});
  save(STORAGE.orders,orders);
  cart=[]; persistCart(); updateCartCount();
  alert("Đặt hàng thành công! Đơn hàng đã được lưu trong website demo.");
  showPage("orders");
}

function renderOrders() {
  const mine = orders.filter(o => currentUser && (isAdmin() || o.username === currentUser.username));
  document.getElementById("orderHistory").innerHTML = mine.length ? mine.map(o => `
    <div class="order-box">
      <div class="order-head"><b>Đơn #${o.id}</b><span class="status">${escapeHTML(o.status)}</span></div>
      <p class="tiny muted">${escapeHTML(o.createdAt)} · Người nhận: ${escapeHTML(o.customer)}</p>
      <p>${o.items.map(i => `${escapeHTML(i.name)} × ${i.quantity}`).join(", ")}</p>
      <b>${money(o.total)}</b>
    </div>`).join("") : `<div class="empty">Bạn chưa có đơn hàng nào.</div>`;
}

function renderAdmin() {
  document.getElementById("statProducts").textContent = products.length;
  document.getElementById("statOrders").textContent = orders.length;
  document.getElementById("statRevenue").textContent = money(orders.filter(o => o.status !== "Đã hủy").reduce((s,o)=>s+o.total,0));
  document.getElementById("adminProducts").innerHTML = products.map(p => `
    <div class="admin-product">
      <img src="${escapeHTML(p.image)}" alt="" onerror="this.src='https://placehold.co/80'">
      <div class="grow"><b>${escapeHTML(p.name)}</b><small>${escapeHTML(p.category)} · ${money(p.price)}</small></div>
      <button class="text-btn" onclick="editProduct(${p.id})">Sửa</button>
      <button class="text-btn" onclick="deleteProduct(${p.id})">Xóa</button>
    </div>`).join("");
  document.getElementById("adminOrders").innerHTML = orders.length ? orders.map(o => `
    <div class="order-box">
      <div class="order-head"><b>Đơn #${o.id} · ${escapeHTML(o.customer)}</b><b>${money(o.total)}</b></div>
      <p class="tiny muted">${escapeHTML(o.phone)} · ${escapeHTML(o.address)} · Tài khoản: ${escapeHTML(o.username)}</p>
      <select onchange="changeOrderStatus(${o.id},this.value)">
        ${["Chờ xác nhận","Đang giao","Hoàn thành","Đã hủy"].map(s=>`<option ${o.status===s?"selected":""}>${s}</option>`).join("")}
      </select>
    </div>`).join("") : `<div class="empty">Chưa có đơn hàng.</div>`;
}
function resetProductForm() {
  document.getElementById("productForm").reset();
  document.getElementById("editProductId").value = "";
  document.getElementById("productFormTitle").textContent = "Thêm sản phẩm";
}
function editProduct(id) {
  const p = products.find(x=>x.id===id); if(!p) return;
  document.getElementById("editProductId").value=p.id;
  document.getElementById("pName").value=p.name;
  document.getElementById("pCategory").value=p.category;
  document.getElementById("pPrice").value=p.price;
  document.getElementById("pImage").value=p.image;
  document.getElementById("pDescription").value=p.description || "";
  document.getElementById("productFormTitle").textContent="Chỉnh sửa sản phẩm";
  document.getElementById("pName").scrollIntoView({behavior:"smooth",block:"center"});
}
function deleteProduct(id) {
  if(!confirm("Bạn có chắc muốn xóa sản phẩm này?")) return;
  products=products.filter(p=>p.id!==id); save(STORAGE.products,products);
  cart=cart.filter(i=>i.id!==id); persistCart(); updateCartCount();
  renderAdmin(); renderProducts();
}
document.getElementById("productForm").addEventListener("submit",e=>{
  e.preventDefault();
  const id=Number(document.getElementById("editProductId").value);
  const data={name:document.getElementById("pName").value.trim(),category:document.getElementById("pCategory").value,price:Number(document.getElementById("pPrice").value),image:document.getElementById("pImage").value.trim() || "https://placehold.co/600x600/f7f5f0/777?text=STYLE+HUB",description:document.getElementById("pDescription").value.trim()};
  if(!data.name || data.price<1000){alert("Vui lòng nhập tên và giá hợp lệ.");return;}
  if(id){products=products.map(p=>p.id===id?{...p,...data}:p);}
  else products.unshift({id:Date.now(),...data});
  save(STORAGE.products,products); resetProductForm(); renderAdmin(); renderProducts();
  alert("Đã lưu sản phẩm.");
});
function changeOrderStatus(id,status) {
  orders=orders.map(o=>o.id===id?{...o,status}:o); save(STORAGE.orders,orders); renderAdmin();
}

function openAuth(mode="login") {
  authMode=mode;
  document.getElementById("authTitle").textContent=mode==="login"?"Đăng nhập":"Tạo tài khoản";
  document.getElementById("authSubmit").textContent=mode==="login"?"Đăng nhập":"Đăng ký";
  document.getElementById("authPassword").autocomplete=mode==="login"?"current-password":"new-password";
  document.getElementById("authSwitch").textContent=mode==="login"?"Chưa có tài khoản? Đăng ký":"Đã có tài khoản? Đăng nhập";
  document.getElementById("authModal").hidden=false;
}
function closeAuth(){document.getElementById("authModal").hidden=true;}
document.getElementById("authSwitch").addEventListener("click",()=>openAuth(authMode==="login"?"register":"login"));
document.getElementById("authForm").addEventListener("submit",e=>{
  e.preventDefault();
  const username=document.getElementById("authUsername").value.trim();
  const password=document.getElementById("authPassword").value;
  if(username.length<3 || password.length<4){alert("Tên đăng nhập cần ít nhất 3 ký tự, mật khẩu ít nhất 4 ký tự.");return;}
  if(authMode==="register"){
    if(username.toLowerCase()==="admin"){alert("Tên đăng nhập này không được sử dụng.");return;}
    if(users.some(u=>u.username.toLowerCase()===username.toLowerCase())){alert("Tên đăng nhập đã tồn tại.");return;}
    users.push({username,password,role:"customer"}); save(STORAGE.users,users);
    alert("Đăng ký thành công. Hãy đăng nhập.");
    openAuth("login"); document.getElementById("authUsername").value=username; return;
  }
  let user;
  if(username==="admin" && password==="admin123") user={username:"admin",role:"admin"};
  else user=users.find(u=>u.username===username && u.password===password);
  if(!user){alert("Tên đăng nhập hoặc mật khẩu không đúng.");return;}
  currentUser={username:user.username,role:user.role}; save(STORAGE.current,currentUser);
  closeAuth(); updateUserArea();
});
function logout() {
  currentUser=null; localStorage.removeItem(STORAGE.current);
  cart=[]; persistCart(); updateCartCount(); updateUserArea(); showPage("shop");
}
function updateUserArea() {
  const area=document.getElementById("userArea");
  document.getElementById("adminNav").hidden=!isAdmin();
  area.innerHTML=currentUser
    ? `<span class="tiny">Xin chào, <b>${escapeHTML(currentUser.username)}</b></span> <button class="text-btn" onclick="logout()">Đăng xuất</button>`
    : `<button class="outline-btn" onclick="openAuth('login')">Đăng nhập</button>`;
}

updateUserArea();
renderProducts();
updateCartCount();
