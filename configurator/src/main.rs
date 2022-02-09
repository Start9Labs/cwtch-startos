
use std::fs::File;
use std::io::Write;

use hmac::{Hmac, Mac, NewMac};
use sha2::Sha256;

#[derive(serde::Deserialize)]
#[serde(rename_all = "kebab-case")]
struct Config {
    tor_address: String,
    user: String,
    password: String,
}

#[derive(serde::Serialize)]
pub struct Properties {
    version: u8,
    data: Data,
}

#[derive(serde::Serialize)]
pub struct Data {
    #[serde(rename = "Pairing URL")]
    pairing_url: Property<String>,
    username: Property<String>,
    password: Property<String>,
}

#[derive(serde::Serialize)]
pub struct Property<T> {
    #[serde(rename = "type")]
    value_type: &'static str,
    value: T,
    description: Option<String>,
    copyable: bool,
    qr: bool,
    masked: bool,
}

fn main() -> Result<(), anyhow::Error> {
    let config: Config =
        serde_yaml::from_reader(File::open("/root/.cwtch/start9/config.yaml")?)?;
    let tor_address = config.tor_address;
    // let mut mac = Hmac::<Sha256>::new_varkey(b"access-key").unwrap();
    // mac.update(format!("{}:{}", config.user, config.password).as_bytes());
    // let b64_access_key = base64::encode_config(
    //     mac.finalize().into_bytes(),
    //     base64::Config::new(base64::CharacterSet::Standard, false),
    // );
    // let access_key = regex::Regex::new("\\W+")?.replace_all(&b64_access_key, "");
    {
        let mut outfile = File::create("/root/.cwtch/config")?;

        // write!(
        //     outfile,
        //     include_str!("config.template"),
        //     user = config.user,
        //     password = config.password,
        //     access_key = access_key,
        //     tor_address = tor_address,
        // )?;
    }
    serde_yaml::to_writer(
        File::create("/root/.cwtch/start9/stats.yaml")?,
        &Properties {
            version: 2,
            data: Data {
                // pairing_url: Property {
                //     value_type: "string",
                //     value: format!(
                //         "http://{tor_address}:80/?access-key={access_key}",
                //         tor_address = tor_address,
                //         access_key = access_key,
                //     ),
                //     description: Some(
                //         "Scan this with the Spark Wallet Mobile App to connect".to_owned(),
                //     ),
                //     copyable: true,
                //     qr: true,
                //     masked: true,
                // },
                // password: Property {
                //     value_type: "string",
                //     value: format!("{}", config.password),
                //     description: Some(
                //         "Copy this password to login. Change this value in Config.".to_owned(),
                //     ),
                //     copyable: true,
                //     qr: false,
                //     masked: true,
                // },
                // username: Property {
                //     value_type: "string",
                //     value: format!("{}", config.user),
                //     description: Some(
                //         "Copy this username to login. Change this value in Config.".to_owned(),
                //     ),
                //     copyable: true,
                //     qr: false,
                //     masked: false,
                // },
            },
        },
    )?;
    Ok(())
}