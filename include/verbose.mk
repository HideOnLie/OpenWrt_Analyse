# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2006-2020 OpenWrt.org

ifndef OPENWRT_VERBOSE
  OPENWRT_VERBOSE:=
endif

# origin 函数用于获取一个变量的定义位置和类型
ifeq ("$(origin V)", "command line")
  OPENWRT_VERBOSE:=$(V)
endif

ifeq ($(OPENWRT_VERBOSE),1)
  OPENWRT_VERBOSE:=w
endif
ifeq ($(OPENWRT_VERBOSE),99)
  OPENWRT_VERBOSE:=s
endif

# 带 V=s 的 make
ifeq ($(NO_TRACE_MAKE),)
NO_TRACE_MAKE := $(MAKE) V=s$(OPENWRT_VERBOSE)
export NO_TRACE_MAKE
endif

ifeq ($(IS_TTY),1)
  ifneq ($(strip $(NO_COLOR)),1)
    _Y:=\\033[33m
    _R:=\\033[31m
    _N:=\\033[m
  endif
endif

define ERROR_MESSAGE
  printf "$(_R)%s$(_N)\n" "$(1)" >&8
endef

ifeq ($(findstring s,$(OPENWRT_VERBOSE)),)
# 如果命令行设置的不是V=99
  define MESSAGE
	printf "$(_Y)%s$(_N)\n" "$(1)" >&8
  endef

  ifeq ($(QUIET),1)
    ifneq ($(CURDIR),$(TOPDIR))
# 绝对路径修改为相对路径, 为了打印美观
      _DIR:=$(patsubst $(TOPDIR)/%,%,${CURDIR})
    else
      _DIR:=
    endif

# 打印 log, 就是设置了 V=1 后会看到的 make log, 这里的 _NULL 应该是没有被引用的, 只是用于调用函数
    _NULL:=$(if $(MAKECMDGOALS),$(shell \
		$(call MESSAGE, make[$(MAKELEVEL)]$(if $(_DIR), -C $(_DIR)) $(MAKECMDGOALS)); \
    ))

    SUBMAKE=$(MAKE)
  else
    SILENT:=>/dev/null $(if $(findstring w,$(OPENWRT_VERBOSE)),,2>&1)
    export QUIET:=1

# 用 shell 函数封装了 make
# -s silent,安静的, 不打印执行命令前的回显
# $@ 表示shell函数中传入的所有参数
# < /dev/null 表示立刻结束输入
    SUBMAKE=cmd() { $(SILENT) $(MAKE) -s "$$@" < /dev/null || { echo "make $$*: build failed. Please re-run make with -j1 V=s or V=sc for a higher verbosity level to see what's going on"; false; } } 8>&1 9>&2; cmd
  endif

  .SILENT: $(MAKECMDGOALS)
else
# 如果命令行设置的是V=99

# 设置 -w 参数, 打印工作目录
  SUBMAKE=$(MAKE) -w
  define MESSAGE
    printf "%s\n" "$(1)"
  endef
endif
