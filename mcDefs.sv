package mcDefs;

parameter	BUSWIDTH = 16;
parameter	DATAPAYLOADSIZE = 4;
parameter	MEMSIZE = 4096;

// page number for the memory controller
parameter [3:0] MEMPAGE1 = 4'h2;

// NOT USED IN THE REFERENCE CODE PROVIDED WITH THE RELEASE BUT MAY BE
// USEFUL IN YOUR CPU/TESTBENCH AND MEMORY_IF CODE.  THEY ARE PROVIDED
// AS A CONVENIENCE AND DO NOT HAVE TO BE USED
typedef struct packed {
	logic		[3:0]	page;
	logic		[11:0]	loc;
} memAddr_t;

typedef union packed {
	memAddr_t			PgLoc;
	logic		[15:0]	ma;	
} areg_t;

endpackage
