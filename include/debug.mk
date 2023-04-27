# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2007-2020 OpenWrt.org

# 要使用这部分 debug 功能, 执行 make 时，可以指定 $(DEBUG) 与 $(DEBUG_SCOPE_DIR) 变量的值，如DEBUG=all make

# debug flags:
#
# d: show subdirectory tree
# t: show added targets
# l: show legacy targets
# r: show autorebuild messages
# v: verbose (no .SILENCE for common targets)

ifeq ($(DUMP),)
  ifeq ($(DEBUG),all)
    build_debug:=dltvr
  else
    build_debug:=$(DEBUG)
  endif
endif

ifneq ($(DEBUG),)

# $(1) 代表传入文件的路径, 如果设置了 $(DEBUG_SCOPE_DIR) 变量, 会判断其是否在 $(DEBUG_SCOPE_DIR) 中, 在的话才进行 flag 匹配
# $(2) 是传入的 debug flag 值
# 成功返回 $(2) 的值, 失败返回空
define debug
$$(findstring $(2),$$(if $$(DEBUG_SCOPE_DIR),$$(if $$(filter $$(DEBUG_SCOPE_DIR)%,$(1)),$(build_debug)),$(build_debug)))
endef

# 如果匹配上 debug flag, 打印 warning
define warn
$$(if $(call debug,$(1),$(2)),$$(warning $(3)))
endef

# 如果匹配上 debug flag, 执行 $(3) 定义的动作
define debug_eval
$$(if $(call debug,$(1),$(2)),$(3))
endef

# 如果匹配上 debug flag, 打印 warning, 并执行 $(4) 的动作
define warn_eval
$(call warn,$(1),$(2),$(3)	$(4))
$(4)
endef

else

# Note: 默认调用 warn_eval 的也会执行, 但是不会打印 warning
debug:=
warn:=
debug_eval:=
warn_eval = $(4)

endif

