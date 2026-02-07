'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "bb819d985e2151227c9aa5369d654656",
"version.json": "dd61765ab916f0cdd27330654f7193a6",
"index.html": "bc11776c57ec202e9a544ab51d22866a",
"/": "bc11776c57ec202e9a544ab51d22866a",
"main.dart.js": "54a0fec0be02dd44269a3defc5db8dd6",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "42cca1daaf42c2242dfc9088f284d532",
"assets/AssetManifest.json": "737745ac94256c23156f76438622537c",
"assets/NOTICES": "dde2edf13c8cbfb17714d12e1a6d61af",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "76b96898a362720b73d382385f5decb8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "911036cd6e1aa387db077b8039dfec6e",
"assets/fonts/MaterialIcons-Regular.otf": "2581961e02424358ac56a7a9231bdc33",
"assets/assets/images/restaurants.png": "7301ed3258e7151fe4571e301448590d",
"assets/assets/images/shawarma.png": "fcf386b58db817daced2d006e0aa121d",
"assets/assets/images/kfc.png": "32d3f2812e700df98791b1c2140b64ad",
"assets/assets/images/banner.png": "6f2d0bed69837aab20ac2bd8963fa87e",
"assets/assets/images/kfc_food.png": "aaccdddff05dc62d2fb214f615c7d396",
"assets/assets/images/kfc_logo.png": "d6ad113dbb09387f6ca552fb271f7b7b",
"assets/assets/images/food.png": "d821983d749590723422c02fb893791a",
"assets/assets/images/skyscraper.png": "88d9498596c66633ee5f3504383d0e98",
"assets/assets/images/biriyani.png": "98e2c458a6165fa1e53a527f7ebb56dd",
"assets/assets/images/burger.png": "88b63ea6972d27cdee27932a9a4e0269",
"assets/assets/images/bg.png": "1ceefcc9fd0f9d51c94f33495d99c206",
"assets/assets/icons/Search.svg": "a9e302ad596e2e96d45f14d1d9e3faea",
"assets/assets/icons/file%2520(1).png": "fdf6a730583879af0ceec907733c5134",
"assets/assets/icons/restaurant.svg": "ed00812e37d256a3070dcb4619b48912",
"assets/assets/icons/home.svg": "4b28899f03c099254f81e023d2d6cefc",
"assets/assets/icons/map.svg": "c48dc0fec9fb314554cd58793aec7cd6",
"assets/assets/icons/discount.png": "89e3453a91a3facac0c67ab2696c59f1",
"assets/assets/icons/order.png": "4852da728be87b6639b3cc65f27126b8",
"assets/assets/icons/success.json": "3986c6bbbb3c88dec60b3d5fa568af0a",
"assets/assets/icons/file.png": "dcc626b70335a4792da2a34855883f6e",
"assets/assets/icons/order.svg": "8f93488cfa1c84c24104d03126b5030c",
"assets/assets/icons/home.png": "f57db47d10f091d8444fcc4295956854",
"assets/assets/icons/user.png": "bd24e3342da244c385754240a951c6c2",
"assets/assets/icons/category.svg": "7aa6e9888a1eb9e601628693e1009943",
"assets/assets/icons/search.png": "618f1cfbbabf85fd0943bcec95c38de3",
"assets/assets/icons/heart.png": "1ddb3dcc4954036cc5375965181e23b4",
"assets/assets/icons/iphone.png": "1a083bb1e430b7a38cc6f53c2899db6f",
"assets/assets/icons/logo.png": "67e9885cd34ded93d77fe31e6d388805",
"assets/assets/icons/money.png": "fe7d120014010e2f1e6adad44a2e00d9",
"assets/assets/icons/home-address.png": "f395f6ccc29ebb9b078df53812394e08",
"assets/assets/icons/location.png": "4ab92a923b10587ac9a2bcb082dfe082",
"assets/assets/icons/call.png": "06d334ab9b4889723ac849edd7eaf08b",
"assets/assets/icons/profile.svg": "e0ae47d341187e61904950a2c17eb930",
"assets/assets/icons/categories.png": "7ce9420e29bbfa27b8e4a8a40d575c6e",
"assets/assets/icons/mastercard.png": "5c567833295e22ec191c1e70c5ddba87",
"assets/assets/icons/chat.png": "52bbdf95236e0b49a51ca32d1047ef1b",
"assets/assets/icons/coupon.png": "9df85cbab4ca98aa85e95ad4127fb2e6",
"assets/assets/icons/message.png": "a125c2323ee4bea2abf0d5e3a1377e1a",
"assets/assets/icons/bag.png": "d5039e0adf491735e537436b9463b544",
"assets/assets/icons/file%2520(2).png": "d53b3a625334153e5353d568c2fbbffd",
"assets/assets/icons/people.png": "3a0719e5ff7beb667f51df8f2932af0e",
"assets/assets/lottie/load.json": "ef70a3a390adc17d5fe6bcb77c5ec214",
"assets/assets/lottie/no.json": "3422d9b04daf4ecde03e2e468a7a54d7",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
