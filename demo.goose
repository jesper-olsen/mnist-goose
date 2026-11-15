// Demo for mnist.goose, after the mnist-rs demo binary: loads a dataset directory
// and shows one image as ASCII art.
//
//   goose demo.goose -- --data-dir MNIST/ --image-number 2 --dataset train
//   goose build demo.goose && ./demo --data-dir MNIST/ --dataset test --image-number 100
import mnist;
import os;

fn fail(msg: u8[:]) {
    write_stderr(str("error: ", msg, "\n"));
    exit(1);
}

fn main() {
    let argv = args();
    var data_dir: const u8[:] = "";
    var dataset: const u8[:] = "train";
    var image_number = 0;
    var i = 1;
    while i < argv.len {
        let a = argv[i];
        guard i + 1 < argv.len else { fail(str("missing value for ", a)); }
        if a == "--data-dir" || a == "-d" { data_dir = argv[i + 1]; }
        else if a == "--dataset" { dataset = argv[i + 1]; }
        else if a == "--image-number" || a == "-i" {
            let n, ok = parse_int(argv[i + 1]);
            guard ok && n >= 0 else { fail(str("bad image number: ", argv[i + 1])); }
            image_number = n;
        } else { fail(str("unknown option: ", a)); }
        i += 2;
    }
    guard data_dir.len > 0 else { fail("usage: demo --data-dir <DIR> [--image-number N] [--dataset train|test]"); }

    print("Attempting to load MNIST data from: ", data_dir, "...");
    var data = mnist::Mnist { .. };
    let err = mnist::load(data_dir, data);
    guard mnist::is_ok(err) else { fail(str(err)); }
    print("✓ Successfully loaded ", data.train_labels.len, " training labels.");
    print("✓ Successfully loaded ", data.train_images.len, " training images.");
    print("✓ Successfully loaded ", data.test_labels.len, " test labels.");
    print("✓ Successfully loaded ", data.test_images.len, " test images.");

    if dataset == "train" {
        guard image_number < data.train_images.len else { fail("Image number out of range"); }
        print("\n--- Dataset: train | Image #", image_number, " | Label: ", data.train_labels[image_number], " ---");
        print(data.train_images[image_number]);
    } else if dataset == "test" {
        guard image_number < data.test_images.len else { fail("Image number out of range"); }
        print("\n--- Dataset: test | Image #", image_number, " | Label: ", data.test_labels[image_number], " ---");
        print(data.test_images[image_number]);
    } else {
        fail("expected train or test");
    }
    print("\nDemo finished successfully!");
}
