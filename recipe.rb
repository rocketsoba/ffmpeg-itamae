# coding: utf-8
if node["platform"] != "redhat" && node["platform_version"] != 6.8 then
  exit(1)
end

directory "/tmp/work"
directory "/home/"+node["userdata"]["name"]+"/opt"

execute "build yasm" do
  cwd "/tmp/work/"
  user node["userdata"]["name"]
  command <<-EOH
if [ ! -d /tmp/work/yasm ]; then
  git clone --depth 1 https://github.com/yasm/yasm.git
fi

cd yasm

if [ ! -d /home/#{node["userdata"]["name"]}/opt/yasm ]; then
  autoreconf -i
  ./configure --prefix=/home/#{node["userdata"]["name"]}/opt/yasm;
  make -j4;
  make install;
fi
EOH
  not_if "env PATH=$PATH:/home/#{node["userdata"]["name"]}/opt/yasm/bin which yasm"
end

execute "build x264" do
  cwd "/tmp/work/"
  user node["userdata"]["name"]
  command <<-EOH
if [ ! -d /tmp/work/x264 ]; then
  git clone --depth 1 https://git.videolan.org/git/x264.git
fi

cd x264

if [ ! -d /home/#{node["userdata"]["name"]}/opt/x264 ]; then
  env PATH=$PATH:/home/#{node["userdata"]["name"]}/opt/yasm/bin ./configure --prefix=/home/#{node["userdata"]["name"]}/opt/x264 --enable-static --disable-shared 
  env PATH=$PATH:/home/#{node["userdata"]["name"]}/optyasm/bin make -j4;
  make install;
fi
EOH
  not_if "env PATH=$PATH:/home/#{node["userdata"]["name"]}/opt/x264/bin which x264"
end

execute "build lame" do
  cwd "/tmp/work/"
  user node["userdata"]["name"]
  command <<-EOH
if [ ! -e /tmp/work/lame-3.99.5.tar.gz ]; then
  wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
fi

if [ ! -d /tmp/work/lame-3.99.5 ]; then
  tar xf lame-3.99.5.tar.gz
fi

cd lame-3.99.5

if [ ! -d /home/#{node["userdata"]["name"]}/opt/lame ]; then
  ./configure --prefix=/home/#{node["userdata"]["name"]}/opt/lame --enable-shared --enable-static
  make -j4;
  make install;
fi
EOH
  not_if "env PATH=$PATH:/home/#{node["userdata"]["name"]}/opt/lame/bin which lame"
end

execute "build fdk-aac" do
  cwd "/tmp/work/"
  user node["userdata"]["name"]
  command <<-EOH
if [ ! -d /tmp/work/fdk-aac ]; then
  git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git
fi

cd fdk-aac

if [ ! -d /home/#{node["userdata"]["name"]}/opt/fdk-aac ]; then
  autoreconf -i
  ./configure --prefix=/home/#{node["userdata"]["name"]}/opt/fdk-aac --disable-shared --enable-static
  make -j4;
  make install;
fi
EOH
  not_if "test -e /home/#{node["userdata"]["name"]}/opt/fdk-aac/lib/libfdk-aac.a "
end

execute "build ffmpeg" do
  cwd "/tmp/work/"
  user node["userdata"]["name"]
  command <<-EOH
if [ ! -e /tmp/work/ffmpeg-3.2.4.tar.xz ]; then
  wget http://ftp.osuosl.org/pub/blfs/conglomeration/ffmpeg/ffmpeg-3.2.4.tar.xz
fi

if [ ! -d /tmp/work/ffmpeg-3.2.4 ]; then
  tar xf ffmpeg-3.2.4.tar.xz
fi

cd ffmpeg-3.2.4

if [ ! -d /home/#{node["userdata"]["name"]}/opt/ffmpeg ]; then
  env PATH=${PATH}:/home/#{node["userdata"]["name"]}/opt/yasm/bin PKG_CONFIG_PATH=/home/#{node["userdata"]["name"]}/opt/fdk-aac/lib/pkgconfig:/home/#{node["userdata"]["name"]}/opt/x264/lib/pkgconfig CFLAGS="-I/home/#{node["userdata"]["name"]}/opt/lame/include" LDFLAGS='-L/home/#{node["userdata"]["name"]}/opt/lame/lib' ./configure --enable-gpl --enable-nonfree --enable-static --disable-shared --enable-libfdk-aac --enable-libmp3lame --enable-libx264 --disable-gnutls --enable-openssl --prefix=/home/#{node["userdata"]["name"]}/opt/ffmpeg
  env PATH=${PATH}:/home/#{node["userdata"]["name"]}/opt/yasm/bin make -j4;
  make install;
fi
EOH
  not_if "env PATH=$PATH:/home/#{node["userdata"]["name"]}/opt/ffmpeg/bin which ffmpeg"
end

# directory "/tmp/work" do
#   action :delete
# end


