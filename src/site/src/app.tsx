import React from "react";
import Web3 from "web3";
import { blockchainConfig } from "./configs";

export const App: React.FC = () => {
  const [account, setAccount] = React.useState<any>();
  const [longevity, setLongevity] = React.useState<any>();
  const [imageId, setImageId] = React.useState<string>();
  const [contractVersion, setContractVersion] = React.useState<string>();
  const [imageData, setImageData] = React.useState<any>();

  React.useEffect(() => {
    async function load() {
      const web3 = new Web3(Web3.givenProvider || "http://localhost:7545");
      const accounts = await web3.eth.requestAccounts();
      setAccount(accounts[0]);

      const longevity = new web3.eth.Contract(
        blockchainConfig.abi as any,
        blockchainConfig.address
      );

      const contractVersion = await longevity?.methods.getVersion().call();

      setContractVersion(contractVersion);

      setLongevity(longevity);
    }

    load();
  }, []);

  const getImageData = async () => {
    if (!imageId) {
      return;
    }

    const imageData = await longevity?.methods.getImageData(imageId).call();

    setImageData(imageData);
  };

  console.log("App", { longevity, contractVersion });

  return (
    <div>
      <h1>Your account is: {account}</h1>
      {/* <div className="m-6">{imageId && JSON.stringify(imageData)}</div> */}
      <form>
        <div className="form-control">
          <label className="label">
            <span className="label-text">Username</span>
          </label>
          <input
            type="text"
            placeholder="Image Id"
            className="input input-bordered"
            onChange={(evt) => {
              setImageId(evt.currentTarget.value);
            }}
            value={imageId}
          />
        </div>
      </form>
      <div className="m-6">
        <button
          className="btn"
          onClick={() => {
            if (imageId) {
              longevity.methods.UploadImage(imageId).call();
            }
          }}
        >
          Upload Image
        </button>
        <button
          className="btn"
          onClick={() => {
            if (imageId) {
              longevity.methods.Vote(imageId).call();
            }
          }}
        >
          Vote
        </button>
        <button
          className="btn"
          onClick={() => {
            if (imageId) {
              longevity.methods.InnapropriateVote(imageId).call();
            }
          }}
        >
          InnapropriateVote
        </button>
        <button className="btn" onClick={getImageData}>
          GetImageData
        </button>
      </div>
    </div>
  );
};
