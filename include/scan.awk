BEGIN { FS="/" }
$1 ~ /^feeds/ { FEEDS[$NF]=$0 }
$1 !~ /^feeds/ { PKGS[$NF]=$0 }
END {
	# Filter-out OpenWrt packages which have a feeds equivalent
	# 如果 feeds 中有同名的 packages 则, 保留 feeds 的那一个
	for (pkg in PKGS)
		if (pkg in FEEDS) {
			print PKGS[pkg] > of
			delete PKGS[pkg]
		}
	n = asort(PKGS)
	for (i=1; i <= n; i++) {
		print PKGS[i]
	}
	n = asort(FEEDS)
	for (i=1; i <= n; i++){
		print FEEDS[i]
	}
}
