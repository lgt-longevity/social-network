import React from "react";
import Web3 from "web3";
import { blockchainConfig } from "./configs";

export const App: React.FC = () => {
  const [account, setAccount] = React.useState<any>();
  const [longevity, setLongevity] = React.useState<any>();
  const [imageId, setImageId] = React.useState<string>();
  const [blockchainData, setSetBlockchainData] = React.useState<any>();

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
      const name = await longevity?.methods.name().call();

      longevity
        .getPastEvents("Logger")
        .then((res) => console.log("events", { res }));

      setSetBlockchainData((val: any) => ({ ...val, contractVersion, name }));

      setLongevity(longevity);
    }

    load();
  }, []);

  const handleGetImageData = React.useCallback(async () => {
    if (!imageId) {
      return;
    }

    const imageData = await longevity?.methods.getImageData(imageId).call();

    setSetBlockchainData((val: any) => ({ ...val, imageData }));
  }, [imageId, longevity]);

  const handleUploadImage = React.useCallback(async () => {
    if (!imageId) {
      return;
    }

    const uploadImage = await longevity?.methods
      .UploadImage(imageId)
      .send({ from: account });

    setSetBlockchainData((val: any) => ({
      ...val,
      uploadImage,
    }));
  }, [account, imageId, longevity]);

  const handleVote = React.useCallback(async () => {
    if (!imageId) {
      return;
    }

    const vote = await longevity?.methods.Vote(imageId).send({ from: account });

    setSetBlockchainData((val: any) => ({
      ...val,
      vote,
    }));
  }, [account, imageId, longevity]);

  const handleInnapropriateVote = React.useCallback(async () => {
    if (!imageId) {
      return;
    }

    const innapropriateVote = await longevity?.methods
      .InnapropriateVote(imageId)
      .send({ from: account });

    setSetBlockchainData((val: any) => ({
      ...val,
      innapropriateVote,
    }));
  }, [account, imageId, longevity]);

  const handleGetContestsLength = React.useCallback(async () => {
    const contestsLength = await longevity?.methods.contestsLength().call();

    setSetBlockchainData((val: any) => ({
      ...val,
      contestsLength,
    }));
  }, [longevity]);

  console.log("App", { longevity, blockchainData });

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
        <button className="btn" onClick={handleUploadImage}>
          Upload Image
        </button>
        <button className="btn" onClick={handleVote}>
          Vote
        </button>
        <button className="btn" onClick={handleInnapropriateVote}>
          InnapropriateVote
        </button>
        <button className="btn" onClick={handleGetImageData}>
          GetImageData
        </button>
        <button className="btn" onClick={handleGetContestsLength}>
          Get Contests Length
        </button>
      </div>
    </div>
  );
};
