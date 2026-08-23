# Qemu / KVM installieren

Die Installation von Windows 11 als Gast unter Ubuntu 24.04 mit QEMU/KVM erfordert einige spezielle Vorbereitungen, da Windows 11 zwingend TPM 2.0 und Secure Boot voraussetzt. Zudem müssen die VirtIO-Treiber manuell während der Installation geladen werden, da Windows die virtuelle Festplatte sonst nicht erkennt.

Hier ist die genaue Schritt-für-Schritt-Anleitung, um das System optimal mit 3D-Beschleunigung einzurichten.

## 1.Host-System vorbereiten: Notwendige Pakete unter Ubuntu 24.04 installieren.

Öffne ein Terminal und installiere die benötigten Pakete für QEMU, KVM, den Virtual Machine Manager (virt-manager) sowie die TPM-Emulation (Software-TPM).

Bash

```
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager swtpm swtpm-tools ovmf virt-viewer
```

Füge danach deinen Benutzer zur Gruppe `libvirt` hinzu, damit du VMs ohne Root-Rechte verwalten kannst:

Bash

```
sudo usermod -aG libvirt $USER
```

*Tipp: Melde dich danach einmal vom System ab und wieder an (oder starte den Rechner neu), damit die Gruppenänderung aktiv wird.*

## 2.ISOs herunterladen: Windows 11 und VirtIO-Treiber besorgen.

Du benötigst zwei Image-Dateien:

1. **Windows 11 ISO:** Lade die offizielle Windows 11 ISO direkt von der Microsoft-Website herunter.

2. **VirtIO-Treiber-ISO:** Lade die neuesten VirtIO-Treiber für Windows herunter. Fedora hostet diese offiziell. Du findest das aktuelle ISO hier: 
   
       wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

## 3.VM erstellen & Installation pausieren: Wichtig: Konfiguration vor der Installation anpassen.

Öffne den **Virtual Machine Manager** und klicke auf "Neue virtuelle Maschine erstellen".

1. Wähle **Lokales Installationsmedium (ISO-Abbild oder CDROM)**.

2. Wähle deine heruntergeladene **Windows 11 ISO** aus (das System sollte als Windows 11 erkannt werden).

3. Weise Arbeitsspeicher (mindestens 4096 MB, besser 8192 MB) und CPUs (mindestens 4 Kerne) zu.

4. Erstelle eine Festplatte (mindestens 64 GB).

5. **Ganz wichtig im letzten Schritt:** Setze einen Haken bei **Konfiguration vor der Installation bearbeiten** und klicke auf "Fertigstellen". Die VM startet nun noch nicht, sondern öffnet die Hardware-Details.

## 4.UEFI und TPM 2.0 konfigurieren: Grundvoraussetzungen für Windows 11.

Im sich nun öffnenden Einstellungsfenster musst du die Systemarchitektur anpassen:

1. **Übersicht (Overview):** Ändere unter *Hypervisor-Details* die Firmware auf **UEFI (OVMF_CODE_4M.ms.fd oder ähnlich mit "secboot")**. Speichere mit "Anwenden".

2. Klicke unten auf **Hardware hinzufügen**.

3. Wähle **TPM**.

4. Setze den Typ auf **Emuliert** (Emulated), das Modell auf **TIS** und die Version zwingend auf **2.0**. Klicke auf "Fertigstellen".

## 5.VirtIO und 3D-Beschleunigung einrichten: Festplatte, Netzwerk und Grafik anpassen.

Nun passen wir die Hardware für maximale Performance an:

1. **SATA/IDE-Festplatte:** Wähle deine virtuelle Festplatte aus. Ändere den "Disk bus" (Festplatten-Bus) auf **VirtIO**. (Das sorgt für eine viel schnellere Laufwerksgeschwindigkeit).

2. **Netzwerk (NIC):** Wähle die Netzwerkkarte an und ändere das "Device model" (Gerätemodell) ebenfalls auf **virtio**.

3. **Zweites CD-ROM-Laufwerk hinzufügen:** Klicke auf "Hardware hinzufügen" -> "Speicher" -> "CDROM-Gerät". Binde hier deine heruntergeladene **virtio-win.iso** ein.

4. **Display Spice:** Wähle links "Display Spice". Setze den "Listen type" auf **None** (Keine) und aktiviere unten das Häkchen bei **OpenGL**. Wähle in der Dropdown-Liste deine Grafikkarte aus.

5. **Video (Grafikkarte):** Wähle links "Video QXL" (oder ähnlich). Ändere das Modell auf **Virtio** und setze rechts das Häkchen bei **3D-Beschleunigung (3D acceleration)**.

Klicke oben links auf **Installation beginnen**.

## 6.Windows 11 installieren & VirtIO Treiber laden:**Die Festplatte während des Setups sichtbar machen.

Die VM bootet nun in das Windows-Setup. Folge den Schritten bis zur Auswahl der Festplatte. **Das Feld wird leer sein**, da Windows VirtIO nicht nativ kennt.

1. Klicke auf **Treiber laden (Load driver)**.

2. Klicke auf **Durchsuchen** und wähle dein zweites CD-Laufwerk (die VirtIO-ISO) aus.

3. Navigiere zu `viostor` -> `w11` -> `amd64`. Bestätige mit OK. Der "Red Hat VirtIO SCSI" Treiber wird installiert. Danach erscheint deine Festplatte.

4. *Wichtig:* Bevor du weitergehst, wiederhole den Vorgang (Treiber laden), um das Netzwerk ans Laufen zu bekommen. Navigiere zu `NetKVM` -> `w11` -> `amd64`. Wenn du das nicht tust, zwingt dich Windows 11 später offline in eine Sackgasse.

5. Wähle nun die Festplatte aus und installiere Windows ganz normal.

## 7.Post-Installation: Guest Tools installieren:**Volle Auflösung und Clipboard-Sharing aktivieren.

Sobald du auf dem Windows 11 Desktop angekommen bist, fehlt noch ein letzter Schritt für die perfekte Integration:

1. Öffne den Windows-Explorer und navigiere zu deinem VirtIO-CD-Laufwerk.

2. Führe die Datei **virtio-win-guest-tools.exe** aus und installiere sie (einfach alles mit "Weiter" bestätigen).

Das installiert die restlichen Treiber (z. B. den VirtIO-Grafiktreiber für die 3D-Beschleunigung und den Baloon-Memory-Treiber) sowie den SPICE-Agenten. Danach kannst du die Fenstergröße der VM dynamisch ändern, Text zwischen Ubuntu und Windows kopieren und die 3D-Beschleunigung der Desktop-Oberfläche nutzen.

> **Hinweis zur 3D-Beschleunigung (VirtIO-GPU):** Die `virtio-vga` 3D-Beschleunigung, die du im Setup aktiviert hast, leitet OpenGL-Befehle (über das *Virgl*-Projekt) an dein Host-System weiter. Das macht die Windows-Oberfläche (Animationen, Fenster) spürbar flüssiger. Für echtes, ressourcenintensives 3D-Gaming unter Windows (DirectX) ist diese Methode jedoch oft nicht leistungsstark oder kompatibel genug.

# Tipps

## Thin Provisioning

### So aktivieren Sie Thin Provisioning (Image schrumpfen)

```bash
# 1. VM vor dem Vorgang unbedingt herunterfahren!
# 2. Image konvertieren (erstellt eine schlanke Kopie)
qemu-img convert -O qcow2 original.qcow2 thin_image.qcow2
```

### Auswirkungen auf die Performance

Ein Thin-Provisioning-Image verhält sich performancetechnisch anders als ein vollständig vorab zugewiesenes (preallocated) Image:

| Kriterium                 | Thin Provisioning (Standard qcow2)             | Volle Vorabzuweisung (Preallocated)     |
|:------------------------- |:---------------------------------------------- |:--------------------------------------- |
| **Erster Schreibvorgang** | **Langsamer** (Host muss neuen Block zuweisen) | **Schnell** (Blöcke existieren bereits) |
| **Folgeschreibvorgänge**  | **Schnell** (Block existiert bereits)          | **Schnell** (Maximaler Durchsatz)       |
| **Lesegeschwindigkeit**   | **Normal**                                     | **Optimal** (Weniger Fragmentierung)    |
| **CPU-Last (Host)**       | **Minimal erhöht** beim Erweitern              | **Sehr niedrig**                        |

### 1. Die "Metadata Allocation"-Verzögerung

Wenn die VM Daten in einen Bereich schreibt, der noch nie benutzt wurde, muss QEMU auf dem Host-Dateisystem neuen Platz anfordern und die internen qcow2-Metadatentabellen aktualisieren. Dies führt beim ersten Schreibvorgang zu einer kurzen Verzögerung (Latenz-Spike). Sobald der Block einmal zugewiesen wurde, ist die Schreibgeschwindigkeit bei Folgevorgängen nahezu identisch mit einer echten Festplatte.

### 2. Fragmentierung auf dem Host

Da ein Thin-Image Stück für Stück wächst, werden die Datenblöcke auf Ihrer echten Festplatte (oder SSD) oft nicht hintereinander (kontinuierlich) geschrieben. Auf klassischen Magnfestplatten (HDDs) führt diese Fragmentierung zu spürbaren Performance-Einbußen beim Lesen und Schreiben. Auf modernen SSDs oder NVMe-Drives ist dieser Effekt dank extrem niedriger Suchzeiten kaum noch messbar.

### 3. Risiko des "Host Out of Space"

Dies ist kein direktes Performance-Problem, aber ein Betriebsrisiko: Wenn mehrere VMs mit Thin Provisioning laufen und alle gleichzeitig wachsen, kann die echte Festplatte des Hosts plötzlich zu 100 % voll sein. In diesem Fall friert KVM die VMs sofort ein, um Datenverlust zu verhindern.

## Virtualbox konvertieren

Ja, Sie können ein VirtualBox-Image ganz einfach in das qcow2-Format konvertieren. Da eine komplette virtuelle Maschine (VM) in VirtualBox jedoch aus mehr als nur der Festplatte besteht (z. B. CPU-Einstellungen, RAM, Netzwerk), müssen Sie das Festplatten-Image konvertieren und danach im virt-manager eine neue VM um dieses Image herum bauen. [1, 2, 3]

Bevor Sie beginnen, deinstallieren Sie im laufenden Betrieb der VirtualBox-VM unbedingt die VirtualBox Guest Additions (Gasterweiterungen) und fahren Sie die VM danach komplett herunter. Dies verhindert Treiberkonflikte unter KVM. [1, 4]

Hier sind die zwei gängigsten Wege, je nachdem, wie Ihre VirtualBox-VM vorliegt:

---

### Methode A: Direkt aus der `.vdi`-Festplattendatei (Am schnellsten)

Wenn Sie Zugriff auf die `.vdi`-Datei der VM auf Ihrem Linux-System haben (meist unter `~/VirtualBox VMs/`), können Sie diese direkt umwandeln: [5, 6, 7]

1. Öffnen Sie das Terminal auf Ihrem Host-System.

2. Konvertieren Sie die Datei direkt mit `qemu-img`:
   
   ```bash
   qemu-img convert -f vdi -O qcow2 /pfad/zu/ihrer/festplatte.vdi /var/lib/libvirt/images/meine_neue_vm.qcow2
   ```
   
   *(Das `-f vdi` gibt das Quellformat an, das `-O qcow2` das Zielformat. Wir speichern sie direkt im Standard-Image-Ordner von libvirt.)* [2, 5, 8, 9, 10, 11, 12]

---

### Methode B: Über einen OVA-Export (Sicherste Methode bei Umzügen)

Falls sich VirtualBox auf einem anderen PC (z. B. Windows) befindet, exportieren Sie die VM dort als Appliance im `.ova`-Format. Eine `.ova`-Datei ist im Grunde nur ein TAR-Archiv, das die Festplatte als `.vmdk` enthält. [8, 9, 13, 14]

1. Kopieren Sie die `.ova`-Datei auf Ihren KVM-Host.

2. Entpacken Sie die Datei im Terminal:
   
   ```bash
   tar -xvf meine_vm.ova
   ```
   
   *(Dadurch erhalten Sie eine `.vmdk`-Datei und eine `.ovf`-Datei.)*

3. Konvertieren Sie die extrahierte `.vmdk`-Festplatte in qcow2:
   
   ```bash
   qemu-img convert -f vmdk -O qcow2 meine_vm-disk1.vmdk /var/lib/libvirt/images/meine_neue_vm.qcow2
   ```

### Schritt 2: Die VM im virt-manager einrichten

Nachdem das Image konvertiert und nach `/var/lib/libvirt/images/` verschoben wurde, binden Sie es im virt-manager ein: 

1. Öffnen Sie den virt-manager und klicken Sie auf Neue virtuelle Maschine erstellen.
2. Wählen Sie im ersten Schritt die Option „Vorhandenes Festplatten-Image importieren“ (Import existing disk image).
3. Klicken Sie auf Durchsuchen (Browse), wählen Sie das gerade erstellte Image `meine_neue_vm.qcow2` aus und stellen Sie das passende Betriebssystem ein.
4. Weisen Sie im nächsten Schritt den gewünschten Arbeitsspeicher (RAM) und die CPU-Kerne zu.
5. Vergeben Sie einen Namen für die VM und klicken Sie auf Fertigstellen. [1, 2, 8, 18]

### Wichtiger Boot-Tipp (Falls die VM nicht startet)

## Schritt 1: Das offizielle VirtIO-Treiber-ISO herunterladen

Da Windows diese Treiber nicht mitbringt, müssen Sie das offizielle Treiber-Abbild (ISO) auf Ihrem KVM-Host herunterladen. Öffnen Sie ein Terminal auf dem Host und führen Sie aus:

sudo wget https://fedorapeople.org -O /var/lib/libvirt/images/virtio-win.iso

------------------------------

## Schritt 2: Die VM im virt-manager mit "SATA"-Kompatibilität anlegen

Damit Windows überhaupt erst einmal hochfährt, gaukeln wir ihm zunächst die alte VirtualBox-Hardwareumgebung vor.

1. Erstellen Sie die VM im virt-manager über „Vorhandenes Festplatten-Image importieren“ (wie im vorherigen Schritt beschrieben).
2. Setzen Sie im letzten Schritt des Assistenten unbedingt den Haken bei „Vor dem Installieren die Konfiguration anpassen“ (Customize configuration before install).
3. Klicken Sie links auf die Festplatte und ändern Sie den Bus-Typ im Dropdown-Menü von VirtIO auf SATA. Klicken Sie auf Anwenden. [1] 
4. Klicken Sie unten links auf Hardware hinzufügen, wählen Sie Speicher, stellen Sie den Typ auf CDROM und binden Sie das zuvor heruntergeladene ISO /var/lib/libvirt/images/virtio-win.iso ein.
5. Klicken Sie oben links auf Installation beginnen.

## Schritt 3: VirtIO-Treiber in Windows installieren

Windows sollte nun problemlos über den SATA-Modus hochfahren. Sobald Sie auf dem Desktop sind:

1. Öffnen Sie den Windows-Explorer und wechseln Sie in das virtuelle CD-Laufwerk (virtio-win).
2. Starten Sie die Datei virtio-win-gt-x64.msi (für ein 64-Bit-Windows).
3. Installieren Sie das Paket mit den Standardeinstellungen. Dadurch werden alle wichtigen KVM-Treiber (Netzwerk, Grafik, Festplatte) in Windows hinterlegt.
4. Fahren Sie das Windows-System danach komplett herunter (nicht nur neu starten). 

## Schritt 4: Den Performance-Turbo zünden (Wechsel auf VirtIO)

Nun aktivieren wir die echten KVM-Vorteile, indem wir die emulierte SATA-Hardware durch die schnellen KVM-Direktkanäle ersetzen.

1. Öffnen Sie die VM-Details im virt-manager (blaues Info-Symbol).
2. Klicken Sie links auf Ihre Festplatte und ändern Sie den Bus-Typ jetzt von SATA zurück auf VirtIO.
3. Klicken Sie links auf die Netzwerkkarte (NIC) und ändern Sie das Gerätemodell auf virtio.
4. Wichtig: Aktivieren Sie bei der Festplatte unter Erweiterte Optionen auch gleich wieder den Verwerfungsmodus: unmap (für das Thin Provisioning).
5. Klicken Sie auf Anwenden und starten Sie die Windows-VM.

# Freigabe für Gast einrichten

Um Ihr Linux-Home-Verzeichnis im Windows-Gast freizugeben, ist Virtio-FS die modernste, stabilste und performanteste Methode unter KVM/QEMU [1]. Es reicht das Dateisystem direkt vom Linux-Host in die Windows-VM durch.

Da Sie die VirtIO-Treiber bereits in Windows installiert haben, sind die Voraussetzungen auf der Gast-Seite schon erfüllt.

---

## Schritt 1: Speicher-Zuweisung im virt-manager vorbereiten

Ja, das können Sie ab Version 4.0 des virt-managers komplett über die grafische Oberfläche einstellen, ohne jemals die XML-Datei öffnen zu müssen. [1, 2] 
Die Entwickler haben dafür ein einfaches Kontrollkästchen integriert: [1] 

## So aktivieren Sie den Shared Memory in der GUI

1. Schalten Sie die Windows-VM komplett aus.
2. Öffnen Sie die Hardware-Details der VM (das blaue Info-Symbol).
3. Klicken Sie in der linken Spalte auf den Reiter Arbeitsspeicher (oder Memory).
4. Auf der rechten Seite sehen Sie nun die RAM-Größe und darunter verschiedene Optionen. Setzen Sie dort einfach den Haken bei „Gemeinsamen Arbeitsspeicher aktivieren“ (englisch: Enable shared memory).
5. Klicken Sie unten rechts auf Anwenden.

## Schritt 2: virtiofsd Treiber installieren

    sudo apt update
    sudo apt install virtiofsd

## Schritt 3: Das Linux-Home-Verzeichnis hinzufügen

1. Klicken Sie unten links im virt-manager auf Hardware hinzufügen (Add Hardware).

2. Wählen Sie in der linken Liste den Punkt Dateisystem (Filesystem).

3. Tragen Sie folgende Werte ein:
   
   - Typ (Type): `virtiofs` (Wichtig: Nicht *mount* oder *template* wählen).
   
   - Quellpfad (Source path): `/home/IHR_BENUTZERNAME` (Klicken Sie auf *Durchsuchen*, um Ihr echtes Home-Verzeichnis zu wählen).
   
   - Zielpfad (Target path): `linux_home` (Dies ist ein frei wählbarer Name, den Windows später als Kennung nutzt – merken Sie sich diesen Namen).

4. Klicken Sie auf Fertigstellen und starten Sie die Windows-VM.

## Schritt 4: WinFsp manuell installieren / reparieren

Obwohl die `virtio-win-gt-x64.msi` versucht, alles Notwendige zu installieren, wird die WinFsp-Komponente manchmal übersprungen oder fehlerhaft registriert.

1. Laden Sie die aktuelle, stabile Version von **WinFsp** direkt von der offiziellen GitHub-Seite im Windows-Gast herunter:  
   [https://github.com/winfsp/winfsp/releases](https://github.com/winfsp/winfsp/releases)
2. Starten Sie den Installer und achten Sie darauf, bei den Installationsoptionen **alle Features auszuwählen** (insbesondere die *Core*-Komponenten).
3. Starten Sie die Windows-VM nach der Installation einmal komplett neu.

## Schritt 5: Den Dienst in Windows starten

Damit Windows das Dateisystem einbinden kann, muss der passende VirtIO-Hintergrunddienst laufen.

1. Starten Sie die Windows-VM und öffnen Sie das Startmenü.
2. Suchen Sie nach „Dienste“ (Services) und öffnen Sie die App als Administrator.
3. Suchen Sie in der Liste nach dem Dienst „VirtIO-FS Service“.
4. Machen Sie einen Rechtsklick darauf, wählen Sie Eigenschaften, stellen Sie den *Starttyp* auf Automatisch und klicken Sie auf Starten. [1]

## 

## Schritt 6: Das Laufwerk im Windows-Explorer mounten

Nachdem der Dienst läuft, binden Sie den Ordner als reguläres Netzlaufwerk ein.

1. Öffnen Sie den Windows-Explorer und klicken Sie links auf Dieser PC.

2. Klicken Sie oben im Menü auf die drei Punkte `...` (oder im alten Windows-Menü) und wählen Sie Netzlaufwerk verbinden (Map network drive).

3. Wählen Sie einen Wunsch-Buchstaben (z. B. `L:`).

4. Tragen Sie im Feld *Ordner* exakt diesen Pfad ein (ersetzen Sie `linux_home` durch den Namen aus Schritt 2):
   
   ```text
   \\virtiofs\linux_home
   ```

5. Setzen Sie den Haken bei „Verbindung bei Anmeldung wiederherstellen“.

6. Klicken Sie auf Fertigstellen. [2, 3, 4]

Ihr Linux-Home-Verzeichnis erscheint nun als vollwertige Festplatte im Windows-Explorer. Daten, die Sie dort hineinkopieren oder ändern, sind sofort und ohne Verzögerung auf Ihrem Linux-Host verfügbar.

# Mehrere Bildschirme

Um mit mehreren Bildschirmen zu arbeiten:

    
