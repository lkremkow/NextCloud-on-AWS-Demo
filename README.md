# NextCloud on AWS Demo

  A Makefile to configure NextCloud from an AMI of Debian 9.9 in AWS EC2.

  Further provides sample files for necessary arguments to configure Qualys services, to copy and paste values during setup.


## Notes

   Required for use:
   - bash 
   - make

   Tested under:
   - MacOS 10.14
   - Debian GNU/Linux 9 (Stretch)


## Installation

   `git clone git@github.com:lkremkow/NextCloud-on-AWS-Demo.git NextCloud-on-AWS-Demo`

   `cd NextCloud-on-AWS-Demo`

   Edit the `Makefile` to provide your account specific details:

   * TARGETHOST for the IP address of the AWS EC2 instance that will be your web server
   * TARGETPORT the port SSH is listening on, 22 by default
   * TARGETUSER the username of the EC2 root/administrator account
   * AWSIDFILE where your SSH keyfile for AWS is stored
   * edit `ActivationId=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa CustomerId=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` to include references to your ActivationId and CustomerId

   Ensure that your SSL certificates are available in the file `ncaws-certs.tar`.


## Usage

   See the [video](https://vimeo.com/342539930).

   Be sure to go fetch the latest version of the Qualys Cloud Agent binary. It should be in this directory, named `qualys-cloud-agent.x86_64.deb`.

   Edit the `Qualys_*` files and complete the needed information to be able to simply copy and paste the needed information later.


## Contributing

   Please see [GitHub](https://github.com/lkremkow/NextCloud-on-AWS-Demo).


## History

   18 June 2019: first version published


## Credits

   TODO


## License

   MIT License

   Copyright (c) 2019 Leif Kremkow <kremkow@tftg.net> (http://www.tftg.com)

   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
