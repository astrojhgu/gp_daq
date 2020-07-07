use super::super::msg_def::msg::TrendMsg;
use bytes::BytesMut;
//use tokio::codec::Decoder;
use tokio_util::codec::Decoder;

use std;

pub struct MsgDecoder {}

impl Decoder for MsgDecoder {
    type Item = TrendMsg;
    type Error = std::io::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        let mut buff = vec![];
        buff.extend_from_slice(&src);
        Ok(TrendMsg::from_byte_vec(buff))
    }
}
