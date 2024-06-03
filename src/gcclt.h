#define GCCLT_MAJOR ${gcclt:Major}
#define GCCLT_MINOR ${gcclt:Minor}
#define GCCLT_PATCH ${gcclt:Patch}
#define GCCLT_SUFFIX "${gcclt:Suffix}"

#define GCCLT_VERSION_CODE ${gcclt:Version}
#define GCCLT_VERSION(X,Y,Z) (((X) <= 2 && (Y) <= 8) ? (X) * 1000 + (Y) * 100 + (Z) : (X) * 10000 + (Y) * 100 + (Z))
