################################################################################
#
# luajit
#
################################################################################

LUAJIT_OPENIPC_VERSION = 880ca300e8fb7b432b9d25ed377db2102e4cb63d
LUAJIT_OPENIPC_SITE = $(call github,LuaJIT,LuaJIT,$(LUAJIT_OPENIPC_VERSION))
LUAJIT_OPENIPC_LICENSE = MIT
LUAJIT_OPENIPC_LICENSE_FILES = COPYRIGHT
LUAJIT_OPENIPC_CPE_ID_VENDOR = luajit
BR_NO_CHECK_HASH_FOR += $(LUAJIT_OPENIPC_SOURCE)
LUAJIT_OPENIPC_INSTALL_STAGING = YES

LUAJIT_OPENIPC_PROVIDES = luainterpreter

ifeq ($(BR2_PACKAGE_LUAJIT_OPENIPC_COMPAT52),y)
LUAJIT_OPENIPC_XCFLAGS += -DLUAJIT_ENABLE_LUA52COMPAT
endif

# The luajit build procedure requires the host compiler to have the
# same bitness as the target compiler. Therefore, on a x86 build
# machine, we can't build luajit for x86_64, which is checked in
# Config.in. When the target is a 32 bits target, we pass -m32 to
# ensure that even on 64 bits build machines, a compiler of the same
# bitness is used. Of course, this assumes that the 32 bits multilib
# libraries are installed.
ifeq ($(BR2_ARCH_IS_64),y)
LUAJIT_OPENIPC_HOST_CC = $(HOSTCC)
# There is no LUAJIT_ENABLE_GC64 option.
else
LUAJIT_OPENIPC_HOST_CC = $(HOSTCC) -m32
LUAJIT_OPENIPC_XCFLAGS += -DLUAJIT_OPENIPC_DISABLE_GC64
endif

# emulation of git archive with .gitattributes & export-subst
# Timestamp of the $(LUAJIT_VERSION) commit, obtained in the LuaJit
# repo, with:   git show -s --format=%ct $(LUAJIT_VERSION)
define LUAJIT_OPENIPC_GEN_RELVER_FILE
	echo 1394627047 >$(@D)/.relver
endef
LUAJIT_OPENIPC_POST_EXTRACT_HOOKS = LUAJIT_OPENIPC_GEN_RELVER_FILE
HOST_LUAJIT_OPENIPC_POST_EXTRACT_HOOKS = LUAJIT_OPENIPC_GEN_RELVER_FILE

# We unfortunately can't use TARGET_CONFIGURE_OPTS, because the luajit
# build system uses non conventional variable names.
define LUAJIT_OPENIPC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) PREFIX="/usr" \
		STATIC_CC="$(TARGET_CC)" \
		DYNAMIC_CC="$(TARGET_CC) -fPIC" \
		TARGET_LD="$(TARGET_CC)" \
		TARGET_AR="$(TARGET_AR) rcus" \
		TARGET_STRIP=true \
		TARGET_CFLAGS="$(TARGET_CFLAGS)" \
		TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
		HOST_CC="$(LUAJIT_HOST_CC)" \
		HOST_CFLAGS="$(HOST_CFLAGS)" \
		HOST_LDFLAGS="$(HOST_LDFLAGS)" \
		BUILDMODE=static \
		XCFLAGS="$(LUAJIT_XCFLAGS)" \
		-C $(@D) amalg
endef

define LUAJIT_OPENIPC_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) PREFIX="/usr" DESTDIR="$(STAGING_DIR)" LDCONFIG=true -C $(@D) install
endef

define LUAJIT_OPENIPC_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) PREFIX="/usr" DESTDIR="$(TARGET_DIR)" LDCONFIG=true -C $(@D) install
endef

define LUAJIT_OPENIPC_INSTALL_SYMLINK
	ln -fs luajit $(TARGET_DIR)/usr/bin/lua
endef
LUAJIT_OPENIPC_POST_INSTALL_TARGET_HOOKS += LUAJIT_OPENIPC_INSTALL_SYMLINK


$(eval $(generic-package))
$(eval $(host-generic-package))