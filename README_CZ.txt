ČASOVAČ ESP – ANDROID APLIKACE
================================

Co aplikace umí
---------------
- Vlastní ikona „Časovač ESP“ na ploše Androidu.
- Uloží až tři ESP8266 časovače pod vlastními názvy (např. Zahrada, Garáž, Obývák).
- Každý časovač má vlastní adresu.
- Webové rozhraní se otevírá uvnitř aplikace, nikoli v Chrome.
- Adresu lze zadat ručně nebo zařízení vyhledat přes mDNS/DNS-SD.
- Uložené názvy a adresy zůstávají v telefonu i po zavření aplikace.
- Aplikace používá existující webové API a stránku ESP8266; ovládání časovače v ESP se nemění.

DŮLEŽITÉ – AUTOMATICKÉ VYHLEDÁVÁNÍ
---------------------------------
V dodaném souboru ESP8266_Casovac_upraveny.ino je WiFi.hostname("ESP8266-Casovac"),
ale není zapnutý mDNS responder ani inzerování HTTP služby. Samotný DHCP hostname
není pro vyhledání Androidem přes NSD dostačující.

Do začátku sketch přidej:

    #include <ESP8266mDNS.h>

V části globálních proměnných přidej:

    bool mdnsStarted = false;

V manageWiFi(), uvnitř bloku:

    if (connected && !wasConnected) {

po server.begin(); serverStarted = true; přidej:

    mdnsStarted = MDNS.begin("esp8266-casovac");
    if (mdnsStarted) {
      MDNS.addService("http", "tcp", 80);
      Serial.println("mDNS: esp8266-casovac.local");
    }

V bloku odpojení Wi-Fi (if (!connected && wasConnected)) přidej:

    if (mdnsStarted) {
      MDNS.close();
      mdnsStarted = false;
    }

Do loop() přidej před yield():

    if (mdnsStarted) MDNS.update();

Po nahrání firmware bude zařízení inzerovat HTTP službu s názvem
esp8266-casovac a Android aplikace ho bude moci nalézt. Pro další ESP8266
použij odlišný hostname, například esp8266-zahrada a esp8266-garaz.

Ruční zadání IP adresy funguje i bez této úpravy firmware.

SESTAVENÍ APK V ANDROID STUDIU
------------------------------
1. Nainstaluj Android Studio a v SDK Manageru Android SDK Platform 35.
2. Rozbal CasovacAndroid.zip do složky v počítači.
3. V Android Studiu zvol Open a vyber složku CasovacAndroid.
4. Počkej na Gradle Sync. První spuštění stáhne Gradle 8.9 a Android Gradle Plugin,
   takže počítač musí mít přístup k internetu. Použij JDK 17 nebo JDK dodávané
   s Android Studiem.
5. Zvol Build > Build Bundle(s) / APK(s) > Build APK(s).
6. APK najdeš v app/build/outputs/apk/debug/app-debug.apk.
7. Přenes APK do telefonu a nainstaluj. Android může požádat o povolení instalace
   aplikací z daného zdroje.

Alternativně lze v Linuxu sestavit APK z terminálu příkazem:
    ./gradlew assembleDebug
Ve Windows použij:
    .\gradlew.bat assembleDebug

POUŽITÍ
-------
1. Telefon musí být připojen ke stejné místní Wi-Fi jako ESP8266.
2. Spusť aplikaci Časovač ESP.
3. U zařízení zvol Nastavit a zadej vlastní název a IP adresu, nebo použij
   Vyhledat ESP8266 v síti (po doplnění mDNS do firmware).
4. Vyber nalezené zařízení a jednu ze tří pozic.
5. Zvol Otevřít. Webová stránka ESP se zobrazí přímo v aplikaci.

POZNÁMKY
--------
- Aplikace očekává současné cesty /, /api/status a /save z dodaného sketch.
- Každé zařízení musí být dostupné z telefonu ve stejné lokální síti.
- Automatické vyhledávání je přes mDNS službu _http._tcp.; nejde o skenování
  všech IP adres v síti.
- Pokud router izoluje Wi-Fi klienty nebo blokuje multicast/mDNS, použij ruční IP.
- APK zde nebylo sestaveno, protože toto pracovní prostředí nemá Android SDK ani
  Gradle. Jde o kompletní zdrojový Android Studio projekt.
