Prima di tutto viene eseguito lo script di preinst che si occupa di fare un
dpkg-divert di /etc/memlockd.cfg in /etc/memlockd.cfg.fake e di
/etc/init.d/kexec-load in /etc/init.d/kexec-load.fake, per
evitare che un eventuale aggiornamento di memlockd/kexec-tools vada a cambiare il file di
configurazione ( o meglio ponga strane domande all'utente).

Nel file di postinst viene configurato kexec-load per essere eseguito anche a
runlevel 0 

sed -i 's/6/0 6/' /etc/init.d/kexec-load [0]

viene eseguita la configurazione di memlockd [1] e usato insserv per configurare
l'avvio dei nuovi script custom [2]

Nello script di postrm vengono tolti i divert e ripristinata la conf originale
di kexec-load 

In data troviamo:

/etc/default/kexec

Si occupa fondamentalmente di aggiungere sdmem ai parametri del kernel lanciato
allo spegnimento/riavvio [3]

case "$RUNLEVEL" in
   6)
      APPEND="${APPEND} sdmem=reboot sdmemopts=vllf"
      ;;
   *)
      APPEND="${APPEND} sdmem=halt sdmemopts=vllf"
      ;;


/etc/init.d/tails-reconfigure-memlockd: [4]

Si occupa di configurare memlockd in base al kernel/initrd aggiungendo questi
due alla configurazione. Fa uso di due script di utilita' [5][6] che sembrano
abbastanza generici da funzionare bene anche con Freepto. Visto che non toccano
l'initrd li ho schiaffati nel pacchetto 

/usr/local/bin/tails-get-bootinfo
/usr/local/bin/tails-boot-to-kexec

Stessa cosa,ma per kexec viene fatta da

etc/init.d/tails-reconfigure-kexec [7]

Il messaggio durante lo spegnimento/riavvio e' gestito da

etc/init.d/tails-kexec [8]

Infine la roba che riguarda l'initramfs sta in 

/usr/share/initramfs-tools/scripts/init-premount/sdmem [9]
/usr/share/initramfs-tools/hooks/sdmem [10]

e verra' inserita a tempo di build

[0]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-patches/run_kexec-load_on_halt.diff

[1]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/etc/memlockd.cfg

[2]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-hooks/52-update-rc.d

[3]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/etc/default/kexec

[4]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/etc/init.d/tails-reconfigure-memlockd

[5] https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/usr/local/bin/tails-get-bootinfo

[6]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/usr/local/bin/tails-boot-to-kexec

[7]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/etc/init.d/tails-reconfigure-kexec

[8]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/etc/init.d/tails-kexec

[9]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/usr/share/initramfs-tools/scripts/init-premount/sdmem

[10]
https://git-tails.immerda.ch/tails/plain/config/chroot_local-includes/usr/share/initramfs-tools/hooks/sdmem
