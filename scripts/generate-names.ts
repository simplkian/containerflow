#!/usr/bin/env tsx

/**
 * Deterministic naming generator for ContainerFlow entities.
 * Supports dry-run output for boxes, stands and warehouse containers.
 *
 * Usage examples:
 *   npx tsx scripts/generate-names.ts --boxes
 *   npx tsx scripts/generate-names.ts --boxes --count 50 --sql
 *   npx tsx scripts/generate-names.ts --stands --hall H-E15 --station 07 --count 8 --prefix E
 *   npx tsx scripts/generate-names.ts --warehouses --material CU --count 2 --sql
 */

type Args = {
  boxes?: boolean;
  stands?: boolean;
  warehouses?: boolean;
  count?: number;
  sql?: boolean;
  hall?: string;
  station?: string;
  prefix?: string;
  material?: string;
};

function parseArgs(argv: string[]): Args {
  const args: Args = {};
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    switch (arg) {
      case "--boxes":
        args.boxes = true;
        break;
      case "--stands":
        args.stands = true;
        break;
      case "--warehouses":
        args.warehouses = true;
        break;
      case "--count":
        args.count = Number(argv[i + 1]);
        i++;
        break;
      case "--sql":
        args.sql = true;
        break;
      case "--hall":
        args.hall = argv[i + 1];
        i++;
        break;
      case "--station":
        args.station = argv[i + 1];
        i++;
        break;
      case "--prefix":
        args.prefix = argv[i + 1];
        i++;
        break;
      case "--material":
        args.material = argv[i + 1];
        i++;
        break;
      default:
        break;
    }
  }
  return args;
}

function pad(num: number, width = 3): string {
  return num.toString().padStart(width, "0");
}

function generateBoxes(count: number, asSql: boolean) {
  const boxes = Array.from({ length: count }, (_, idx) => {
    const serial = `BOX-${pad(idx + 1)}`;
    const qrCode = `QR-BOX-${pad(idx + 1)}`;
    return { serial, qrCode };
  });

  if (asSql) {
    const sql = boxes
      .map(
        (b) =>
          `('${b.serial}', '${b.qrCode}', true)`,
      )
      .join(",\n  ");
    console.log("INSERT INTO boxes (serial, qr_code, is_active) VALUES");
    console.log(`  ${sql};`);
  } else {
    console.log(boxes.map((b) => b.serial).join("\n"));
  }
}

function generateStands(hall: string, station: string, count: number, prefix: string, asSql: boolean) {
  const stands = Array.from({ length: count }, (_, idx) => {
    const ident = `${prefix}${pad(idx + 1, 3)}`;
    const code = `SP-${hall.replace(/^H-/, "")}-${station}-${ident}`;
    const qrCode = `QR-${code}`;
    return { identifier: code, qrCode };
  });

  if (asSql) {
    const values = stands
      .map(
        (s) =>
          `( (SELECT id FROM stations WHERE code='ST-${hall.replace(/^H-/, "")}-${station}'), '${s.identifier}', '${s.qrCode}', NULL, 1 )`,
      )
      .join(",\n  ");
    console.log("INSERT INTO stands (station_id, identifier, qr_code, material_id, max_slots) VALUES");
    console.log(`  ${values};`);
  } else {
    stands.forEach((s) => console.log(s.identifier));
  }
}

function generateWarehouses(material: string, count: number, asSql: boolean) {
  const containers = Array.from({ length: count }, (_, idx) => {
    const code = `WC-${material}-${pad(idx + 1, 2)}`;
    const qrCode = `QR-${code}`;
    return { code, qrCode };
  });

  if (asSql) {
    const values = containers
      .map(
        (c) =>
          `('${c.code}', (SELECT id FROM materials WHERE code='${material}'), 10000, 'kg', '${c.qrCode}')`,
      )
      .join(",\n  ");
    console.log("INSERT INTO warehouse_containers (id, material_id, max_capacity, quantity_unit, qr_code) VALUES");
    console.log(`  ${values};`);
  } else {
    containers.forEach((c) => console.log(c.code));
  }
}

function printHelp() {
  console.log(`
Usage:
  --boxes [--count N] [--sql]                Generate BOX-001..N
  --stands --hall H-E15 --station 07 [--count 8] [--prefix E] [--sql]
  --warehouses --material CU [--count 2] [--sql]
`);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const count = args.count && args.count > 0 ? args.count : 0;

  if (args.boxes) {
    generateBoxes(count || 300, !!args.sql);
    return;
  }

  if (args.stands) {
    if (!args.hall || !args.station) {
      console.error("hall und station sind erforderlich für --stands");
      process.exit(1);
    }
    generateStands(args.hall, args.station, count || 8, args.prefix || "A", !!args.sql);
    return;
  }

  if (args.warehouses) {
    if (!args.material) {
      console.error("--material ist erforderlich für --warehouses (z.B. CU)");
      process.exit(1);
    }
    generateWarehouses(args.material, count || 2, !!args.sql);
    return;
  }

  printHelp();
}

main();
