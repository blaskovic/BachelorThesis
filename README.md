# Testovací sada sloužící pro analýzu Tuned profilů

1. Nastudujte službu Tuned a klíčové vlastnosti jejích profilů. Seznamte se s emulací různých druhů diskových zařízení a síťových služeb I/O a testování jejich výkoností.
2. Vytvořte plán testování pro tuned profily na platformě Fedora Linux. Cílem testovacího plánu je analýza, zda Tuned profily splňují požadované vlastnosti.
3. Implementujte automatizované testy pro nástroj Tuned a automatické vyhodnocení výsledků testů.
4. Proveďte testy na nejčastěji používaných diskových zařízeních a souborových systémů. Diskutujte dosažené výsledky.
5. Řešení projektu pravidelně diskutujte s konzultantem projektu.

### Vedoucí:

* Smrčka Aleš, Ing., Ph.D., UITS FIT VUT

### Konzultant:

* Ščotka Jan, Ing., RHcz

***

## Zdroje, pouzite kniznice (zapisnik)

* [BeakerLib](https://fedorahosted.org/beakerlib/)
  * kniznica pre testovanie

* [tuned](https://fedorahosted.org/tuned/)
  * daemon na ladenie systemu

* [qemu-kvm](http://doc.opensuse.org/products/draft/SLES/SLES-kvm_sd_draft/cha.qemu.running.html)
  * zaklady qemu-kvm

* IEEE829 test plan
  * Priklady: [1](http://www.acomtech.com/testplan.html) [2](http://bazman.tripod.com/frame.html) [3](http://futurestuff4all.com/index.php/2011/08/sample-ieee-829-test-case-specification-template/) [4](http://www.gerrardconsulting.com/tkb/guidelines/ieee829/main.html)

* Block devices
  * [1](http://www.chesterproductions.net.nz/blogs/it/sysadmin/configuring-iscsi-targets-and-initiators-on-fedora-16/455/) 
