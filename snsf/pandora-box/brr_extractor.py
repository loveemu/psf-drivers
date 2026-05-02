import csv
import os
import argparse


def main():
    parser = argparse.ArgumentParser(
        description="Extract BRR samples from a ROM file"
    )
    parser.add_argument(
        "rom",
        help="input ROM file path"
    )
    parser.add_argument(
        "csvfile",
        help="path to samples.csv"
    )
    parser.add_argument(
        "-o", "--outdir",
        default="samples",
        help="output directory (default: samples)"
    )

    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    with open(args.rom, "rb") as rom:
        with open(args.csvfile, newline="") as f:
            reader = csv.DictReader(f)

            for row in reader:
                sample_id = int(row["sample"], 16)
                addr = int(row["address"], 16)
                bank = int(row["bank"], 16)
                size = int(row["size"], 16)

                if size == 0:
                    continue

                # decode SNES address (HiROM)
                offset = ((bank & 0x3F) << 16) | addr

                rom.seek(offset)
                data = rom.read(size)

                filename = os.path.join(
                    args.outdir,
                    f"sample_{sample_id:02X}.brr"
                )

                with open(filename, "wb") as out:
                    out.write(data)

                print(
                    f"dumped {filename} "
                    f"(offset={offset:06X}, size={size:04X})"
                )


if __name__ == "__main__":
    main()
